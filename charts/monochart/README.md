# Monochart

This chart is an effort to standardize the Kubernetes resources we deploy to our clusters

Under templates, we define the resources either with sane defaults (in the values.yaml) or enforce that downstream values are supplied to the fields

This chart is built with the assumption it'd be used with helmfile (i.e it doesn't add resource loops, it'd be done in the helmfile)

## Development Guide

When adding a new resource, try to follow these recommendations
1. Try including all the fields avaiable in a resource and set the defaults in values.yaml
2. Never introduce any environment or app specific logic in this chart (It should remain as generic as possible)
