IS_GREEN=$(docker ps | grep accommodation-green) # 현재 실행중인 App이 blue인지 확인
DEFAULT_CONF=" /etc/nginx/nginx.conf"

if [ -z $IS_GREEN  ];then # blue라면 or 첫 배포라면 (환경변수로 설정한 문자열 길이가 0인 경우 -z)

  echo "##### BLUE => GREEN #####"

  echo "1. get green image"
  docker-compose pull accommodation-green # green으로 이미지를 내려받아옴

  echo "2. green container up"
  docker-compose up -d accommodation-green # green 컨테이너 실행

  counter=0
  while [ 1 = 1 ]; do
  echo "3. green health check..."
  ((counter++))
  sleep 3

  REQUEST=$(curl http://127.0.0.1:8082) # green으로 request
    if [ -n "$REQUEST" ]; then # 서비스 가능하면 health check 중지 (문자열 길이가 0보다 큰지 판단 -n)
            echo "health check success"
            echo "Number of attempts: $counter"
            break ;
            fi
  done;

  echo "4. reload nginx"
  sudo cp /etc/nginx/nginx.green.conf /etc/nginx/nginx.conf
  sudo nginx -s reload

  echo "5. blue container down"
  docker-compose stop accommodation-blue
  docker-compose rm -f accommodation-blue
else #
  echo "### GREEN => BLUE ###"

  echo "1. get blue image"
  docker-compose pull accommodation-blue

  echo "2. blue container up"
  docker-compose up -d accommodation-blue


  counter=0
  while [ 1 = 1 ]; do
    echo "3. blue health check..."
    ((counter++))
    sleep 3
    REQUEST=$(curl http://127.0.0.1:8083) # blue로 request

    if [ -n "$REQUEST" ]; then # 서비스 가능하면 health check 중지 (문자열 길이가 0보다 큰지 판단 -n)
      echo "health check success"
      echo "Number of attempts: $counter"
      break ;
    fi
  done;

  echo "4. reload nginx" 
  sudo cp /etc/nginx/nginx.blue.conf /etc/nginx/nginx.conf
  sudo nginx -s reload

  echo "5. green container down"
  docker-compose stop accommodation-green
  docker-compose rm -f accommodation-green
fi