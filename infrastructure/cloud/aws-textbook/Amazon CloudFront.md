# Amazon CloudFront

- Amazon CloudFront는 AWS에서 제공하는 CDN 서비스로 정적 콘텐츠나 동적 콘텐츠를 사용자에게 빠르게 배포하도록 지원하는 서비스
- 전 세계에 분포된 엣지 로케이션(edge location)이라는 곳에 콘텐츠를 캐싱하고 사용자 요청에 따라 가장 지연 시간이 낮은 엣지 로케이션이 응답하여 최적의 성능을 보장

## Amazon CloudFront 구성

- AWS의 글로벌 엣지 네트워크를 이용하여 오리진 대상의 콘텐츠를 전 세계에 위치한 엣지 로케이션과 리전 엣지 캐시에 캐싱하여 CDN 서비스를 제공
- Amazon CloudFront는 48개국 90개 이상의 도시에 위치한 450개 이상의 엣지 로케이션을 두고 AWS 글로벌 네트워크를 활용하여 서비스

### Amazon CloudFront 서비스 구성 요소

1. **오리진**: 원본 콘텐츠를 가지고 있는 대상으로 이 대상은 온프레미스의 일반 서버나 AWS 서비스의 EC2, ELB, S3가 될 수 있음
2. **Distribution**: 오리진과 엣지 중간에서 콘텐츠를 배포하는 역할을 수행하는 CloudFront의 독립적인 단위로 웹 서비스 전용의 Web Distribution과 스트리밍 전용의 RTMP Distribution으로 분류
3. **리전 엣지 캐시**: 빈번하게 사용되는 콘텐츠에 대해 캐싱하는 큰 단위의 엣지 영역으로 오리진과 엣지 로케이션 사이에 위치, 엣지 로케이션에서 오리진으로 콘텐츠를 요청하는 상황을 줄여 효율적으로 CDN 서비스를 제공
4. **엣지 로케이션**: Distribution으로 배포되는 콘텐츠를 캐싱하는 작은 단위의 엣지 영역으로, 사용자 입장에서 가장 인접한 엣지 로케이션이 콘텐츠를 전달

## Amazon CloudFront 기능

### 정적 및 동적 콘텐츠 처리

- Amazon CloudFront는 정적 콘텐츠와 동적 콘텐츠에 최적화된 캐싱 동작을 제공

### HTTPS 기능

- 오리진 대상이 HTTPS를 지원하지 않아도 Amazon CloudFront가 알아서 HTTPS 통신을 중계
- 사용자와 CloudFront는 HTTPS로 통신하고 CloudFront와 오리진은 HTTP로 통신할 수 있음

### 다수의 오리진 선택 기능

- Amazon CloudFront의 단일 Distribution 환경에서 다수의 오리진을 지정하고 선택하여 콘텐츠를 분산 처리할 수 있음

### 접근 제어

- 서명된 URL과 쿠키(cookie)로 사용자 인증을 지원하여 인증된 사용자만 접근할 수 있도록 지원