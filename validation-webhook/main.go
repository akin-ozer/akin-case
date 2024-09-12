package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	admissionv1 "k8s.io/api/admission/v1"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
)

var (
	deserializer       = serializer.NewCodecFactory(runtime.NewScheme()).UniversalDeserializer()
	validationCounter  = prometheus.NewCounterVec(prometheus.CounterOpts{Name: "validation_total", Help: "Total number of validations"}, []string{"result"})
	enabledNamespaces  []string
	configMapName      = "webhook-config"
	configMapNamespace = "default"
)

func init() {
	prometheus.MustRegister(validationCounter)
	loadEnabledNamespaces()
}

func loadEnabledNamespaces() {
	data, err := ioutil.ReadFile(fmt.Sprintf("/etc/config/%s", configMapName))
	if err != nil {
		fmt.Printf("Error reading ConfigMap: %v\n", err)
		os.Exit(1)
	}
	enabledNamespaces = strings.Split(string(data), ",")
}

func main() {
	http.HandleFunc("/validate", validateDeployment)
	http.Handle("/metrics", promhttp.Handler())
	fmt.Println("Starting server on :8080")
	http.ListenAndServeTLS(":8080", "/etc/webhook/certs/tls.crt", "/etc/webhook/certs/tls.key", nil)
}

func validateDeployment(w http.ResponseWriter, r *http.Request) {
	var admissionReview admissionv1.AdmissionReview

	body, _ := ioutil.ReadAll(r.Body)
	if _, _, err := deserializer.Decode(body, nil, &admissionReview); err != nil {
		http.Error(w, fmt.Sprintf("Error decoding admission review: %v", err), http.StatusBadRequest)
		return
	}

	var deployment appsv1.Deployment
	if err := json.Unmarshal(admissionReview.Request.Object.Raw, &deployment); err != nil {
		http.Error(w, fmt.Sprintf("Error unmarshaling deployment: %v", err), http.StatusBadRequest)
		return
	}

	var response admissionv1.AdmissionResponse
	if isNamespaceEnabled(deployment.Namespace) && !hasRequiredResources(deployment.Spec.Template.Spec.Containers) {
		response = admissionv1.AdmissionResponse{
			Allowed: false,
			Result: &metav1.Status{
				Message: "Deployment must specify required CPU and memory resource requests for all containers",
			},
		}
		validationCounter.WithLabelValues("rejected").Inc()
	} else {
		response = admissionv1.AdmissionResponse{Allowed: true}
		validationCounter.WithLabelValues("allowed").Inc()
	}

	response.UID = admissionReview.Request.UID

	responseAdmissionReview := admissionv1.AdmissionReview{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "admission.k8s.io/v1",
			Kind:       "AdmissionReview",
		},
		Response: &response,
	}

	respBytes, err := json.Marshal(responseAdmissionReview)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error marshaling admission review response: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(respBytes)
}

func isNamespaceEnabled(namespace string) bool {
	for _, ns := range enabledNamespaces {
		if ns == namespace {
			return true
		}
	}
	return false
}

func hasRequiredResources(containers []corev1.Container) bool {
	for _, container := range containers {
		if container.Resources.Requests.Cpu().IsZero() || container.Resources.Requests.Memory().IsZero() {
			return false
		}
	}
	return true
}
