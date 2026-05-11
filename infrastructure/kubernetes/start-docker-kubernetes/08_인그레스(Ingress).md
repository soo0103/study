# 인그레스(Ingress)

- 인그레스는 일반적으로 외부에서 내부로 향하는 것
- 인그레스는 외부 요청을 어떻게 처리할 것인지 네트워크 7계층 레벨에서 정의하는 쿠버네티스 오브젝트
    - 외부 요청의 라우팅
        - 특정 경로로 들어온 요청을 어떠한 서비스로 전달할지 정의하는 라우팅 규칙 설정 가능
    - 가상 호스트 기반의 요청 처리
        - 같은 IP에 대해 다른 도메인 이름으로 요청이 도착했을 때, 어떻게 처리할 것인지 정의할 수 있음
    - SSL/TLS 보안 연결 처리
        - 여러 개의 서비스로 요청을 라우팅 시 보안 연결을 위한 인증서를 쉽게 적용할 수 있음

## 인그레스를 사용하는 이유

- 인그레스 오브젝트를 사용하면 엔드포인트를 단 하나만 생성함으로써 디플로이먼트 별로 서비스를 생성해 서비스마다 처리하는 번거로움을 해결할 수 있음
    - 라우팅 정의나 보안 연결 등과 같은 세부 설정은 인그레스에 의해 수행
    - 각 디플로이먼트에 대해 일일이 설정을 적용할 필요 없이 하나의 설정 지점에서 처리 규칙을 정의하면 됨
    
    ⇒ 외부 요청에 대한 처리 규칙을 쿠버네티스 자체의 기능으로 편리하게 관리할 수 있다는 것이 인그레스의 핵심
    

## 인그레스의 구조

- 쿠버네티스에서 ingress라는 이름으로 사용
- `kubectl get ingress` 명령어로 인그레스 목록 확인할 수 있음
    
    ```bash
    kubectl get ingress
    kubectl get ing
    ```
    

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - host: alicek106.example.com
      http:
        paths:
          - path: /echo-hostname
            pathType: Prefix
            backend:
              service:
                name: hostname-service
                port:
                  number: 80
```

- host
    - 해당 도메인 이름으로 접근하는 요청에 대해 처리 규칙을 적용
    - 여러 개의 host 정의 가능
- path
    - 해당 경로에 들어온 요청을 어느 서비스로 전달할 것인지 정의
    - 여러 개의 path로 정의해 경로를 처리할 수 있음
- serviceName, servicePort
    - path로 들어온 요청이 전달될 서비스와 포트

<aside>
💡

인그레스를 정의하는 YAML 파일 중에서 annotation 항목을 통해 인그레스의 추가적인 기능을 사용할 수 있음

</aside>

- 인그레스는 단지 요청을 처리하는 규칙을 정의하는 선언적인 오브젝트이며 외부 요청을 받아들일 수 있는 실제 서버가 아님
- 인그레스는 인그레스 컨트롤러(Ingress Controller)라고 하는 특수한 서버에 적용해야만 그 규칙을 사용할 수 있음
    
    → 실제 외부 요청을 받아들이는 것은 인그레스 컨트롤러 서버이며, 이 서버가 인그레스 규칙을 로드해 사용
    
- 컨트롤러 서버는 여러 종류가 있음
    - 대표적으로 Nginx 웹 서버 인그레스 컨트롤러가 있음
    - 명령어로 리소스 한 번에 설치 가능함
    
    ```bash
    kubectl apply -f \ 
    	https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
    
    ```
    
- 클라우드가 아닌 환경에서 인그레스를 테스트하고 싶으면 NodePort 타입의 서비스를 생성해도 가능함
    
    ```bash
    apiVersion: v1
    kind: Service
    metadata:
      name: ingress-nginx-controller-nodeport
      namespace: ingress-nginx
    spec:
      ports:
        - name: http
          nodePort: 31000
          port: 80
          protocol: TCP
          targetPort: http
        - name: https
          nodePort: 32000
          port: 443
          protocol: TCP
          targetPort: https
      selector:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
      type: NodePort
    ```
    
    - Nginx 인그레스 컨트롤러로 들어오는 요청은 포드들로 분산됨
- 컨트롤러에 설정된 도메인이 아닌 다른 도메인 이름으로 접근한 경우 404 Not Found 에러 발생
- 인그레스 컨트롤러는 항상 인그레스 리소스의 상태를 지켜보며 모든 네임스페이스의 인그레스 리소스를 읽어와 규칙을 적용함
- Nginx 인그레스 컨트롤러는 서비스에 의해 생성된 엔드포인트로 요청을 직접 전달
    - 서비스의 ClusterIP가 아닌 엔드포인트의 실제 종착 지점들로 요청이 전달
        
        → 바이패스(bypass)라 함
        

## 인그레스 세부 기능: annotation을 이용한 설정

- kubernetes.io/ingress-class
    - 해당 인그레스 규칙을 어떤 인그레스 컨트롤러에 적용할 것인지
    - 쿠번네티스 클러스터 자체에서 기본적으로 사용하도록 설정된 인그레스 컨트롤러 존재 시
        
        → 어떤 컨트롤러를 사용할 것인지 명시할 것
        
- nginx.ingress.kubernetes.io/rewrite-target
    - Nginx 인그레스 컨트롤러에서만 사용할 수 있는 기능
    - 인그레스에 정의된 경로로 들어오는 요청을 rewrite-target에 설치된 경로로 전달
    - path에 설정한 경로로 시작하는 모든 요청을 전달
    - Nginx의 캡쳐 그룹과 함께 사용할 때 유용함
        - 캡처 그룹: 정규 표현식의 형태로 요청 경로 등의 값을 변수로서 사용할 수 있는 방법

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2 # path의 (.*)에서 획득한 경로로 전달
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: <nginx 컨트롤러에 접근하기 위한 도메인 이름>
    http:
      paths:
      - path: /echo-hostname(/|$)(.*)
        backend:
          serviceName: hostname-service
          serverPort: 80

```

- path 항목에서 (.*) 정규표현식으로 /echo-hostname 뒤의 경로를 얻은 뒤 이 값을 rewrite-target에서 사용
    
    → 즉, 요청 경로를 다시 쓰는것
    
- app-root
    - 루트 경로 접근 시 특정 path로 리다이렉트
- ssl-redirect
    - SSL 리다이렉트

## Nginx 인그레스 컨트롤러에 SSL/TLS 보안 연결 적용

- 인그레스 장점 중 하나는 인그레스 컨트롤러에서 편리하게 SSL/TLS 보안 연결을 설정할 수 있다는 것
- AWS 같은 클라우드 환경에서 LoadBalancer 타입의 서비스 사용 계획 시 클라우드 플랫폼 자체 인증서를 적용할 수 있음
    - AWS의 ACM(AWS Certificate Manager)
- tls로 secret 생성후
    
    ```yaml
    apiVersion: networking.k8s.io/v1beta1
    kind: Ingress
    metadata:
      name: ingress-example
      annoations:
        nginx.ingress.kubernetes.io/rewrite-target: /
        kubernetes.io/ingress.class: "nginx"
    spec:
      tls:
      - hosts:
        - <도메인 이름>
        secretName: tls-secret # 생성한 secret
      rules:
      - host: <도메인 이름>
        http:
          paths:
          - path: /echo-hostname
            backend:
              serviceName: hostname-service
              servicePort: 80
    ```
    
    - spec.tls.hosts 항목에 보안 연결 적용할 도메인 이름
    - spec.tls.secretName 항목에 tls 타입의 시크릿
- 특정 인그레스에 SSL/TLS가 적용되었을 때 ssl-redirect를 자동으로 true로 설정

## 여러 개의 인그레스 컨트롤러 사용하기

- 하나의 클러스터에서 반드시 하나의 인그레스 컨트롤러를 사용해야 하진 않음
- 여러 개의 컨트롤러르 사용할 수 있음
- 규칙을 선택적으로 적용할 수 있음
- —ingress-class 값이 nginx가 아닌 값이면 이전에 생성했던 규칙은 더 이상 Nginx 인그레스 컨트롤러에 적용되지 않음