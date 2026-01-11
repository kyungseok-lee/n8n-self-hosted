# n8n-self-hosted

n8n을 Docker Compose로 자체 호스팅하는 프로젝트입니다.

## 구성 요소

- **n8n**: 워크플로우 자동화 플랫폼 (포트: 5678)
- **PostgreSQL**: 데이터베이스 (포트: 5432)
- **Qdrant**: 벡터 데이터베이스 (포트: 6333)

## 시작하기

### 1. 환경 변수 설정

`.env` 파일을 생성하고 다음 변수들을 설정하세요:

```bash
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
POSTGRES_DB=your_database_name
N8N_ENCRYPTION_KEY=your_encryption_key
N8N_USER_MANAGEMENT_JWT_SECRET=your_jwt_secret
```

### 2. 데이터 디렉토리 생성

```bash
mkdir -p data/postgres data/n8n data/qdrant
```

### 3. 서비스 시작

```bash
docker compose up -d
```

### 4. 접속

- n8n: http://localhost:5678
- PostgreSQL: localhost:5432
- Qdrant: http://localhost:6333

## 데이터 저장

모든 데이터는 `./data` 디렉토리에 저장됩니다:

- `./data/postgres`: PostgreSQL 데이터
- `./data/n8n`: n8n 워크플로우 및 설정
- `./data/qdrant`: Qdrant 벡터 데이터

## 서비스 중지

```bash
docker compose down
```

데이터를 유지하면서 중지하려면:

```bash
docker compose down
```

데이터까지 삭제하려면:

```bash
docker compose down -v
rm -rf ./data
```

## 주의사항

- `.env` 파일에 민감한 정보가 포함되어 있으므로 Git에 커밋하지 마세요.
- `./data` 디렉토리는 `.gitignore`에 포함되어 있습니다.
