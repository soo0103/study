# State

- 테라폼은 Stateful 애플리케이션
- 프로비저닝 결과에 따른 State를 저장하고 프로비저닝한 모든 내용을 저장된 상태로 추적
- State에는 작업자가 정의한 코드와 실제 반영된 프로비저닝 결과를 저장하고 이 정보를 토대로 리소스 생성, 수정, 삭제에 대한 동작 판단 작업을 수행

## State의 목적과 의미

- State의 역할
    - State에는 테라폼 구성과 실제를 동기화하고 각 리소스에 고유한 아이디(리소스 주소)로 매핑
    - 리소스 종속성과 같은 메타데이터를 저장하고 추적
    - 테라폼 구성으로 프로비저닝된 결과를 캐싱하는 역할을 수행
- State 동작 예시
    
    ```hcl
    resource "random_password" "password" {
      length = 16
      special = true
      override_special = "!#$%"
    }
    ```
    
    ```hcl
    # terraform.state
    {
      "version": 4,
      "terraform_version": "1.14.9",
      "serial": 122,
      "lineage": "7cc671c1-d075-df1c-955e-8f965da4a53a",
      "outputs": {},
      "resources": [
        {
          "mode": "managed",
          "type": "random_password",
          "name": "password",
          "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
          "instances": [
            {
              "schema_version": 3,
              "attributes": {
                "bcrypt_hash": "$2a$10$LOaI1LJGdP4UyOfmDhPIGu1tVMVm7potIY2WSHeBEoUO3SWXz2gv6",
                "id": "none",
                "keepers": null,
                "length": 16,
                "lower": true,
                "min_lower": 0,
                "min_numeric": 0,
                "min_special": 0,
                "min_upper": 0,
                "number": true,
                "numeric": true,
                "override_special": "!#$%",
                "result": "9kJwJojePvXtd8tV",
                "special": true,
                "upper": true
              },
              "sensitive_attributes": [
                [
                  {
                    "type": "get_attr",
                    "value": "bcrypt_hash"
                  }
                ],
                [
                  {
                    "type": "get_attr",
                    "value": "result"
                  }
                ]
              ],
              "identity_schema_version": 0
            }
          ]
        }
      ],
      "check_results": null
    }
    
    ```
    
- 테라폼에서는 JSON 형태로 작성된 State를 통해 속성과 인수를 읽고 확인할 수 있음
- tpye과 name으로 고유한 리소스를 분류, 해당 리소스의 속성과 인수를 구성과 비교해 대상 리소스를 생성, 수정, 삭제
- State는 테라폼만을 위한 API 정의도 가능
    - plan 실행 시 암묵적으로 refresh 동작을 수행하면서 리소스 생성의 대상과 State를 기준으로 비교하는 과정을 거침
        
        → 리소스양에 따라 속도 차이가 발생
        
    - 대량의 리소스를 관리해야 하는 경우 plan 명령에서 -refresh=false 플래그를 사용해 State를 기준으로 실행 계획을 생성하고 이를 실행에 활용해 대상 환경과의 동기화 과정을 생략할 수 있음

## State 동기화

- 테라폼 구성 파일은 기존 State와 구성을 비교해 실행 계획에서 생성, 수정, 삭제 여부를 결정
- 테라폼 구성과 State 흐름
    1. State와 비교
    2. Refresh
    3. create/replace/update/destroy
        
        
        | 기호 | 의미 |
        | --- | --- |
        | + | Create |
        | - | Destroy |
        | -/+ | Replace |
        | ~ | Update in-plance |
    4. State 저장
- Replace 동작은 기본값을 삭제 후 생성
    - lifecycle의 create_before_destroy 옵션으로 생성 후 삭제가 가능
- 리소스와 State에 따른 동작
    
    
    | 유형 | 구성 리소스 정의 | Stat의 구성 데이터 | 실제 리소스 | 기본 예상 동작 |
    | --- | --- | --- | --- | --- |
    | 1 | 있음 |  |  | 리소스 생성 |
    | 2 | 있음 | 있음 |  | 리소스 생성 |
    | 3 | 있음 | 있음 | 있음 | 동작 없음 |
    | 4 |  | 있음 | 있음 | 리소스 삭제 |
    | 5 |  |  | 있음 | 동작 없음 |

### 유형 1

- 테라폼 구성 파일에 신규 리소스를 정의하고 Apply를 수행하면 State에 없는 리소스이므로 생성 작업을 수행
- 실행 동작 검증 예시
    
    ```hcl
    resource "local_file" "foo" {
      content = "foo"
      filename = "${path.module}/foo.txt"
    }
    ```
    
    ```bash
    $ terraform apply -auto-approve
    Acquiring state lock. This may take a few moments...
    
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
    the following symbols:
      + create
    
    Terraform will perform the following actions:
    
      # local_file.foo will be created
      + resource "local_file" "foo" {
          + content              = "foo"
          + content_base64sha256 = (known after apply)
          + content_base64sha512 = (known after apply)
          + content_md5          = (known after apply)
          + content_sha1         = (known after apply)
          + content_sha256       = (known after apply)
          + content_sha512       = (known after apply)
          + directory_permission = "0777"
          + file_permission      = "0777"
          + filename             = "./foo.txt"
          + id                   = (known after apply)
        }
    
    Plan: 1 to add, 0 to change, 0 to destroy.
    local_file.foo: Creating...
    local_file.foo: Creation complete after 0s [id=0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33]
    
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```
    
    ```hcl
    {
      "version": 4,
      "terraform_version": "1.14.9",
      "serial": 126,
      "lineage": "7cc671c1-d075-df1c-955e-8f965da4a53a",
      "outputs": {},
      "resources": [
        {
          "mode": "managed",
          "type": "local_file",
          "name": "foo",
          "provider": "provider[\"registry.terraform.io/hashicorp/local\"]",
          "instances": [
            {
              "schema_version": 0,
              "attributes": {
                "content": "foo",
                "content_base64": null,
                "content_base64sha256": "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564=",
                "content_base64sha512": "9/u6bgY2+JDlb7vzKD5STG+jIErimDgtYkdB0NxmODJuKCxBvl5CVNiCB3LFUYosWowMf37aGVlKfrU5RT4e1w==",
                "content_md5": "acbd18db4cc2f85cedef654fccc4a4d8",
                "content_sha1": "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33",
                "content_sha256": "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae",
                "content_sha512": "f7fbba6e0636f890e56fbbf3283e524c6fa3204ae298382d624741d0dc6638326e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7",
                "directory_permission": "0777",
                "file_permission": "0777",
                "filename": "./foo.txt",
                "id": "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33",
                "sensitive_content": null,
                "source": null
              },
              "sensitive_attributes": [
                [
                  {
                    "type": "get_attr",
                    "value": "sensitive_content"
                  }
                ]
              ],
              "identity_schema_version": 0
            }
          ]
        }
      ],
      "check_results": null
    }
    ```
    

### 유형 2

- 구성 파일에 리소스가 있고 State에도 관련 구성이 있지만 실제 리소스가 없는 경우 생성작업을 수행
- 테라폼으로 프로비저닝을 완료했지만 사용자가 수동으로 인프라를 삭제한 경우에도 해당
    
    ```bash
    $ terraform plan
    ...
    Plan: 1 to add, 0 to change, 0 to destroy.
    ```
    
- -refresh=false 인수를 추가해 plan을 실행한 경우 State만을 확인하므로 리소스를 다시 만드는 작업은 발생하지 않음
    
    ```bash
    $ terraform plan -refresh=false
    Acquiring state lock. This may take a few moments...
    
    No changes. Your infrastructure matches the configuration.
    
    Terraform has compared your real infrastructure against your configuration and found no differences, so no changes
    are needed.
    ```
    

### 유형 3

- 테라폼 구성에 정의된 리소스로 생성된 프로비저닝 결과가 State에 있고 실제 리소스도 있는 경우라면 변경 계획을 발생시키지 않음
    
    ```bash
    $ terraform apply -auto-approve
    ...
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    
    $ terraform  terraform apply -auto-approve
    ...
    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
    ```
    

### 유형 4

- 구성, State, 실제 리소스가 있는 상태에서 테라폼에서 정의한 리소스 구문을 삭제하면 사용자는 의도적으로 해당 리소스를 삭제하는 것
- 테라폼은 구성 파일을 기준으로 State와 비교해 삭제된 구성을 실제 리소스에서 제거
    
    ```bash
    $ terraform plan
    ...
    Plan: 0 to add, 0 to change, 1 to destroy.
    ```
    

### 유형 5

- 이미 만들어진 리소스만 있다면 테라폼의 State에 없는 내용이므로 테라폼으로 관리되지 않음
- 해당 리소스에 대해서는 아무 작업도 수행할 수 없음
    - 처음부터 테라폼으로 관리되지 않는 경우
    - 테라폼으로 생성하고 구성과 State가 삭제된 경우

## 워크스페이스

- State를 관리하는 논리적인 가상 공간을 워크스페이스라 함
- 테라폼 구성 파일은 동일하지만 작업자는 서로 다른 State를 갖는 실제 대상을 프로비저닝할 수 있음
- 기본적으로 default로 정의

> 기본 사용법: terraform [global options] workspace
> 
- terraform workspace list 명령으로 확인해보면 * default가 있음(*는 사용 중)
    
    ```bash
    $ terraform workspace list
    * default
    ```
    
- terraform workspace new <워크스페이스 이름> 명령으로 새로운 워크스페이스를 생성
    
    ```bash
    $ terraform workspace new ws1
    Created and switched to workspace "ws1"!
    ```
    
- 워크스페이스가 생성되면 실행한 루트 모듈 디렉터리에 terraform.tfstate.d 디렉터리가 생성되고 하위에 워크스페이스 이름이 있는 것을 확인할 수 있음
    
    ```bash
    $ terraform workspace show
    ws1
    ```
    
- 새로 생성한 워크스페이스는 default에서 관리하는 State와는 독립된 정보를 갖기 때문에 리소스를 재생성하겠다고 출력
- 테라폼 구성에서 terraform.workspace를 사용해 워크스페이스 이름을 읽으면 워크스페이스 기준으로 문자열을 지정하거나 조건을 부여할 수 있음
- 워크스페이스를 삭제하려는 경우 terraform workspace delete <워크스페이스 이름> 명령어로 삭제
    
    ```bash
    $ terraform workspace delete ws1
    Deleted workspace "ws1"!
    ```
    
- 다수의 워크스페이스 사용하는 것의 장점
    - 하나의 루트 모듈에서 다른 환경을 위한 리소스를 동일한 테라폼 구성으로 프로비저닝하고 관리
    - 기존 프로비저닝된 환경에 영햐을 주지 않고 변경 사항 실험 가능
    - 깃의 브랜치 전략처럼 동일한 구성에서 서로 다른 리소스 결과 관리
- 단점
    - State가 동일한 저장소(로컬 또는 백엔드)에 저장되어 State 접근 권한 관리가 불가능
    - 모든 환경이 동일한 리소스를 요구하지 않을 수 있으므로 테라폼 구성에 분기 처리가 다수 발생 가능
    - 프로비저닝 대상에 대한 인증 요소를 완벽히 분리하기가 어려움
- 워크스페이스는 완벽한 격리가 어려움
    
    → 이를 해결하기 위해 루트 모듈을 별도로 구성하는 디렉터리 기반의 레이아웃을 사용할 수 있음