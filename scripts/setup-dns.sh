#!/bin/bash

echo "🌐 Setting up DNS..."

# Wait for ALB
sleep 60

# Get ALB DNS
ALB_DNS=$(kubectl get ingress voting-app-alb -n voting-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_DNS" ]; then
    echo "❌ ALB not ready. Wait and run: kubectl get ingress -n voting-app"
    exit 1
fi

echo "🎯 ALB DNS: $ALB_DNS"
echo ""
echo "📝 Add to /etc/hosts:"
echo "$ALB_DNS vote.myapp.dev results.myapp.dev"
echo ""
echo "🌐 Access:"
echo "Voting:   http://vote.myapp.dev"
echo "Results:  http://results.myapp.dev"