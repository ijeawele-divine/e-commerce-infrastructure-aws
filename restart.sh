# Restart all backend and frontend services to sync secrets
services=(
  "driver-service"
  "rider-service"
  "matching-service"
  "trip-service"
  "email-service"
  "rideshare-frontend"
)

for service in "${services[@]}"; do
  echo "Restarting $service..."
  kubectl rollout restart deployment/$service
done

# Watch the status of the rollout
kubectl get pods -w