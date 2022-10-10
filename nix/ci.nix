{ pkgs }:

let
  inherit (pkgs) writeScriptBin;

  run = pkg: "${pkgs.${pkg}}/bin/${pkg}";
in
[
  (writeScriptBin "do-authenticate" ''
    ${run "doctl"} auth init --access-token "''${DO_TOKEN}"
  '')

  (writeScriptBin "do-get-kubeconfig" ''
    ${run "doctl"} kubernetes cluster kubeconfig save "''${K8S_CLUSTER_NAME}"
  '')

  (writeScriptBin "k8s-set-ctx" ''
    ${run "kubectx"} "''${K8S_CONTEXT}"
  '')

  (writeScriptBin "k8s-get-nodes" ''
    ${run "kubectl"} get nodes
  '')

  (writeScriptBin "k8s-apply" ''
    ${run "kubectl"} apply --filename ./kubernetes/deployment.yaml
  '')

  (writeScriptBin "k8s-restart-deployment" ''
    ${run "kubectl"} rollout restart deployment.apps/horoscope-deployment
  '')
]
