
#traer de git
git pull origin main

#tumbar contenedores
docker compose down

#levantar contenedores
echo "levantando contenedores..."

docker compose -f docker-compose.prod.yml up -d --build

echo "listo"