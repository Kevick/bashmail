#!/bin/bash

# Definir as informações do banco de dados
DB_HOST="localhost"
DB_NAME="quilometragem"
DB_USER="root"
DB_PASS=""

# Definir as informações do servidor de e-mail
SMTP_SERVER="servidor_smtp"
SMTP_PORT="porta_smtp"
EMAIL_USER="usuario_do_email"
EMAIL_PASS="senha_do_email"
EMAIL_FROM="seu_email@exemplo.com"
EMAIL_TO="email_destino@exemplo.com"
EMAIL_SUBJECT="Manutenção Preventiva Próxima"

# Definir a quantidade de quilômetros que faltam para a próxima manutenção preventiva
KM_THRESHOLD=500

# Realizar a consulta no banco de dados
QUERY="SELECT placa, km_atual, km_prox_manutencao, email FROM quilometragem WHERE km_prox_manutencao - km_atual <= $KM_THRESHOLD"
RESULTS=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME -se "$QUERY")

# Enviar um e-mail para cada veículo que está próximo da próxima manutenção preventiva
while read -r ROW; do
    PLACA=$(echo $ROW | awk '{print $1}')
    KM_ATUAL=$(echo $ROW | awk '{print $2}')
    KM_PROX_MANUTENCAO=$(echo $ROW | awk '{print $3}')
    EMAIL=$(echo $ROW | awk '{print $4}')

    # Construir o corpo do e-mail
    EMAIL_BODY="Olá,\n\nO veículo com a placa $PLACA está com $((KM_PROX_MANUTENCAO - KM_ATUAL)) km restantes antes da próxima manutenção preventiva.\n\nAtenciosamente,\nSistema de Gerenciamento de Frota"

    # Enviar o e-mail
    echo -e "$EMAIL_BODY" | mailx -s "$EMAIL_SUBJECT" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$EMAIL_USER" -S smtp-auth-password="$EMAIL_PASS" -S from="$EMAIL_FROM" "$EMAIL"
done <<< "$RESULTS"