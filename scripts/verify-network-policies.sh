#!/bin/bash

echo "🔍 Verifying Network Policies..."

echo "=== Network Policies ==="
kubectl get networkpolicies -n voting-app

echo ""
echo "=== Testing Connectivity ==="

# Test Vote -> Redis (should work)
VOTE_POD=$(kubectl get pods -l app=vote -n voting-app -o jsonpath='{.items[0].metadata.name}')
echo "Testing Vote -> Redis..."
kubectl exec $VOTE_POD -n voting-app -- sh -c 'timeout 5 nc -zv redis-master 6379 && echo "✅ SUCCESS" || echo "❌ FAILED"'

# Test Worker -> Redis (should work)
WORKER_POD=$(kubectl get pods -l app=worker -n voting-app -o jsonpath='{.items[0].metadata.name}')
echo "Testing Worker -> Redis..."
kubectl exec $WORKER_POD -n voting-app -- sh -c 'timeout 5 nc -zv redis-master 6379 && echo "✅ SUCCESS" || echo "❌ FAILED"'

# Test Worker -> PostgreSQL (should work)
echo "Testing Worker -> PostgreSQL..."
kubectl exec $WORKER_POD -n voting-app -- sh -c 'timeout 5 nc -zv postgresql 5432 && echo "✅ SUCCESS" || echo "❌ FAILED"'

# Test Result -> PostgreSQL (should work)
RESULT_POD=$(kubectl get pods -l app=result -n voting-app -o jsonpath='{.items[0].metadata.name}')
echo "Testing Result -> PostgreSQL..."
kubectl exec $RESULT_POD -n voting-app -- sh -c 'timeout 5 nc -zv postgresql 5432 && echo "✅ SUCCESS" || echo "❌ FAILED"'

# Test Vote -> PostgreSQL (should be blocked)
echo "Testing Vote -> PostgreSQL (should be blocked)..."
kubectl exec $VOTE_POD -n voting-app -- sh -c 'timeout 5 nc -zv postgresql 5432 && echo "❌ UNEXPECTED" || echo "✅ CORRECTLY BLOCKED"'

echo ""
echo "✅ Network policies verification completed"