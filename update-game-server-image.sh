#!/bin/bash

# Script to update game-server image on all nodes
# Usage: ./update-game-server-image.sh [image]
# Example: ./update-game-server-image.sh ghcr.io/marcobrunodev/game-server:banana-server

IMAGE="${1:-ghcr.io/marcobrunodev/game-server:banana-server}"

echo "=========================================="
echo "Updating game-server image"
echo "Image: $IMAGE"
echo "=========================================="
echo ""

PODS=$(kubectl get pods -n 5stack -l app=game-server-node-connector -o name 2>/dev/null)

if [ -z "$PODS" ]; then
  echo "Error: No game-server-node-connector found"
  exit 1
fi

for pod in $PODS; do
  NODE=$(kubectl get $pod -n 5stack -o jsonpath='{.spec.nodeName}')
  echo "=== Updating node: $NODE ==="
  echo "    Pod: $pod"

  kubectl exec -n 5stack $pod -- crictl pull "$IMAGE"

  if [ $? -eq 0 ]; then
    echo "    Done"
  else
    echo "    Error updating image"
  fi
  echo ""
done

echo "=========================================="
echo "Completed!"
echo ""
echo "Next steps:"
echo "1. Recreate game-server pods (warmup/match) to use the new image"
echo "2. Or wait for new pods to be created automatically"
echo "=========================================="
