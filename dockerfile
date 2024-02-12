version: "3"
services:
  frontend:
   #working_dir: /usr/src/app
    build:
      context: ./
      dockerfile: Dockerfile-frontend-worker
    command: ["./wait-for-it.sh", "database:5432", "--", "yarn", "run:server"]
    volumes:
      - volfrontend:/usr/src/app
    environment:
      - DATABASE_HOST=database
      - DATABASE_PORT=5432
    depends_on:
      - database
      - worker
    ports:
      - "3015:3000"
    networks:
      - thimnet

  worker:
    build:
      context: ./
      dockerfile: Dockerfile-frontend-worker
    #working_dir: /usr/src/app
    #volumes:
     # - ./:/usr/src/app
     # - ./storefront-angular-starter-0.1.25:/usr/src/app
    command: ["./wait-for-it.sh", "database:5432", "--", "yarn", "run:worker"]
    environment:
      - DATABASE_HOST=database
      - DATABASE_PORT=5432
    depends_on:
      - database
      #- storefront
    networks:
      - thimnet

  storefront:
   # image: node:14
    build:
      context: ./
      dockerfile: Dockerfile-storefront  
    environment:
      - SERVER_API_HOST=http://server
      - SERVER_API_PORT=3000
      - SERVER_API_PATH=shop-api
    depends_on:
      - database

    expose:
      - "4000"
    ports:
      - "4001:4000"
    networks:
      - thimnet

  database:
    image: postgres:16
    volumes:
      - ./voldb:/var/lib/postgresql/data 
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=vendure
    expose:
      - "5432"
    ports:
      - "5433:5432"
    networks:
      - thimnet

  dbreplica:
    image: postgres:16
    volumes:
      - ./voldbreplica:/var/lib/postgresql/data 
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=vendure
    expose:
      - "5432"
    ports:
      - "5434:5432"
    networks:
      - thimnet   

  mariadb:
    image: mariadb:10.6
    volumes:
      - ./volmariadb:/var/lib/mysql 
    environment:
      - MYSQL_ROOT_PASSWORD=password
    expose:
      - "3306"
    ports:
      - "3310:3306"
    networks:
      - thimnet 

  wordpress:
    image: wordpress:4.7-php7.1-apache
    volumes:
      - ./wordpress:/var/www/html
    environment:
      - MONEI_OPERATION_MODE=live
      - MONEI_TEST_CHANNEL_ID=test_channel_id
      - MONEI_TEST_USER_ID=test_user_id
      - MONEI_TEST_PASSWORD=test_password
      - MONEI_LIVE_CHANNEL_ID=live_channel_id
      - MONEI_LIVE_USER_ID=live_user_id
      - MONEI_LIVE_PASSWORD=live_password
      - WORDPRESS_DB_HOST=mariadb:3306
      - WORDPRESS_DB_PASSWORD=password
      - WORDPRESS_SITE_TITLE=some_site_title
      - WORDPRESS_ADMIN_PASSWORD=1234
    expose:
      - "80"
      - "443"
    ports:
      - "3500:80"
      - "4500:443"
    depends_on:
      - mariadb
    networks:
      - thimnet 

  redis:
    image: redis:6.0-alpine
    volumes:
      - ./redisdata:/data
    expose:
      - "6379"
    ports:
      - "6380:6379"
    networks:
      - thimnet 

  redis1:
    image: redis:6.0-alpine
    volumes:
      - ./redisdata1:/data
    expose:
      - "6379"
    ports:
      - "6381:6379"
    networks:
      - thimnet 

  redis2:
    image: redis:6.0-alpine
    volumes:
      - ./redisdata2:/data
    expose:
      - "6379"
    ports:
      - "6382:6379"
    networks:
      - thimnet 

  sentinel01:
    image: redis:6.0-alpine
    volumes:
      - ./sentinel01:/etc/redis/sentinel.conf
    networks:
      - thimnet
    depends_on:
      - redis

  sentinel02:
    image: redis:6.0-alpine
    volumes:
      - ./sentinel02:/etc/redis/sentinel.conf
    networks:
      - thimnet
    depends_on:
      - redis

  sentinel03:
    image: redis:6.0-alpine
    volumes:
      - ./sentinel03:/etc/redis/sentinel.conf
    networks:
      - thimnet
    depends_on:
      - redis

networks:
  thimnet:
    driver: bridge

volumes:
  volfrontend:
    driver: local
  #yarn:
   # driver: local
  #storefront-angular-starter-0.1.25:
  #  driver: local
  voldb:
    driver: local
  voldbreplica:
    driver: local
  volmariadb:
    driver: local
  wordpress:
    driver: local
  redisdata:
    driver: local
  redisdata1:
    driver: local
  redisdata2:
    driver: local
