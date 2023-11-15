for arq in ./*.sql; do
        echo "Executando $arq ..."
        psql -h siter-3.csf4qwhttixg.us-east-1.rds.amazonaws.com -U user_buscaterra -d siter -f "$arq"
done
