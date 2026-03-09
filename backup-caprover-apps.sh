#!/bin/bash

# --- CONFIGURAÇÕES ---
NOME_APP="meuelevador"         # Nome do app no CapRover
CONTAINER_DB="srv-captain--$NOME_APP-db" # Nome padrão do container DB no CapRover
CONTAINER_SITE="srv-captain--$NOME_APP-com"
USER_DB="root"              
SENHA_DB="SUA-SENHA-AQUI"        # Senha do banco de dados
NOME_DB="meuelevador"              # Nome do banco de dados

DIRETORIO_BACKUP="/home/ubuntu/scripts"
 
NOME_ARQUIVO="dump_$(date +%d-%m-%Y_%H_%M_%S).sql"
NOME_COMPACTADO="database_$(date +%d-%m-%Y_%H_%M_%S)"
REMOTE_RCLONE="gdrive:Backups"   # Nome do remote no rclone e a pasta

# Criar pasta temporária se não existir
mkdir -p $DIRETORIO_BACKUP

echo "--- Iniciando backup de $NOME_APP ---"

docker exec -it $(docker ps --filter name=$CONTAINER_DB -q) sh -c ' mariadb-dump -u '$USER_DB' -p'$SENHA_DB' --all-databases' > $NOME_ARQUIVO

echo "--- Compactando arquivo de banco de dados $NOME_APP ---"

tar -czf $DIRETORIO_BACKUP/$NOME_COMPACTADO.tar.gz $DIRETORIO_BACKUP/$NOME_ARQUIVO

echo "--- Fazendo backup do wordpress $NOME_APP ---"

#docker exec -it $(docker ps --filter name=srv-captain--meuelevador-com -q) \ tar -czf  /var/www/vhosts/localhost/html \ > wordpress.tar.gz

docker exec -i $(docker ps -qf name=$CONTAINER_SITE) \
tar -czf - -C /var/www/vhosts/localhost html \
> wordpress.tar.gz 

# 3. Upload para Google Drive via Rclone
# echo "Enviando para o Google Drive..."
# rclone move $DIRETORIO_BACKUP/$NOME_ARQUIVO $REMOTE_RCLONE

# # 4. Limpeza
rm $DIRETORIO_BACKUP/$NOME_ARQUIVO

echo "Log de backup executada em: $(date)" >> $DIRETORIO_BACKUP/log_backup.txt

echo "Upload para o Google Drive"

rclone sync /home/ubuntu/scripts/ gdrive:/backup

rm $DIRETORIO_BACKUP/$NOME_COMPACTADO.tar.gz
rm $DIRETORIO_BACKUP/wordpress.tar.gz

echo "--- Backup concluído com sucesso em $(date) ---"




