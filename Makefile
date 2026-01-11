.PHONY: help backup restore list-backups clean-backups

# 변수 설정
BACKUP_DIR := ./backups
DATA_DIR := ./data
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
BACKUP_FILE := $(BACKUP_DIR)/n8n-backup-$(TIMESTAMP).tar.gz

# 기본 타겟
help:
	@echo "n8n-self-hosted 백업 관리"
	@echo ""
	@echo "사용 가능한 명령어:"
	@echo "  make backup          - ./data 디렉토리를 백업합니다"
	@echo "  make restore BACKUP_FILE=<파일경로> - 백업 파일을 복원합니다"
	@echo "  make list-backups    - 백업 파일 목록을 표시합니다"
	@echo "  make clean-backups   - 30일 이상 된 백업 파일을 삭제합니다"
	@echo "  make help            - 이 도움말을 표시합니다"
	@echo ""

# 백업 생성
backup:
	@if [ ! -d "$(DATA_DIR)" ]; then \
		echo "❌ $(DATA_DIR) 디렉토리가 존재하지 않습니다."; \
		exit 1; \
	fi
	@mkdir -p $(BACKUP_DIR)
	@echo "📦 백업 생성 중: $(BACKUP_FILE)"
	@tar -czf $(BACKUP_FILE) -C . data
	@echo "✅ 백업 완료: $(BACKUP_FILE)"
	@ls -lh $(BACKUP_FILE)

# 백업 목록 보기
list-backups:
	@if [ ! -d "$(BACKUP_DIR)" ] || [ -z "$$(ls -A $(BACKUP_DIR) 2>/dev/null)" ]; then \
		echo "📭 백업 파일이 없습니다."; \
	else \
		echo "📋 백업 파일 목록:"; \
		echo ""; \
		ls -lh $(BACKUP_DIR)/n8n-backup-*.tar.gz 2>/dev/null | awk '{print "  " $$9 " (" $$5 ")"}'; \
	fi

# 백업 복원
# 사용법: make restore BACKUP_FILE=./backups/n8n-backup-20240101_120000.tar.gz
restore:
	@if [ -z "$(BACKUP_FILE)" ]; then \
		if [ ! -d "$(BACKUP_DIR)" ] || [ -z "$$(ls -A $(BACKUP_DIR)/n8n-backup-*.tar.gz 2>/dev/null)" ]; then \
			echo "❌ 복원할 백업 파일이 없습니다."; \
			exit 1; \
		fi; \
		echo "📋 사용 가능한 백업 파일:"; \
		ls -1t $(BACKUP_DIR)/n8n-backup-*.tar.gz 2>/dev/null | nl; \
		echo ""; \
		echo "사용법: make restore BACKUP_FILE=./backups/n8n-backup-YYYYMMDD_HHMMSS.tar.gz"; \
		exit 1; \
	fi
	@if [ ! -f "$(BACKUP_FILE)" ]; then \
		echo "❌ 백업 파일을 찾을 수 없습니다: $(BACKUP_FILE)"; \
		exit 1; \
	fi
	@echo "⚠️  경고: 현재 $(DATA_DIR) 디렉토리의 데이터가 덮어씌워집니다."
	@echo "🔄 복원 중: $(BACKUP_FILE)"
	@if [ -d "$(DATA_DIR)" ]; then \
		echo "📦 기존 데이터 백업 중..."; \
		mkdir -p $(BACKUP_DIR)/pre-restore-$(TIMESTAMP); \
		mv $(DATA_DIR) $(BACKUP_DIR)/pre-restore-$(TIMESTAMP)/data-$(TIMESTAMP) 2>/dev/null || true; \
	fi
	@tar -xzf "$(BACKUP_FILE)" -C .
	@echo "✅ 복원 완료: $(BACKUP_FILE)"

# 오래된 백업 삭제 (30일 이상)
clean-backups:
	@if [ ! -d "$(BACKUP_DIR)" ] || [ -z "$$(ls -A $(BACKUP_DIR)/n8n-backup-*.tar.gz 2>/dev/null)" ]; then \
		echo "📭 삭제할 백업 파일이 없습니다."; \
		exit 0; \
	fi
	@echo "🧹 30일 이상 된 백업 파일 삭제 중..."
	@find $(BACKUP_DIR) -name "n8n-backup-*.tar.gz" -type f -mtime +30 -delete
	@echo "✅ 정리 완료"
	@make list-backups
