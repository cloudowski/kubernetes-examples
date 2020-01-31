vault auth enable oidc
vault write auth/oidc/config  oidc_client_id="xcxc" oidc_client_secret="dsdsdsds" default_role="default" oidc_discovery_url=https://gitlab.gitlab.test1.k8sworkshops.com

vault write auth/oidc/role/default user_claim="sub"     allowed_redirect_uris="http://localhost:8250/oidc/callback,https://vault.test1.k8sworkshops.com/ui/vault/auth/oidc/oidc/callback" role_type="oidc" oidc_scopes="openid"  groups_claim="groups"     token_policies=default
