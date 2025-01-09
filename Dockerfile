FROM node:18-alpine

WORKDIR /app

# package.json'ı kopyala ve bağımlılıkları yükle
COPY package*.json ./
RUN npm install

# Tüm kaynak kodları kopyala
COPY . .

# Build time değişkeni ekle (her build'de farklı olacak)
ARG BUILD_DATE
ENV BUILD_DATE=${BUILD_DATE}

EXPOSE 3125

CMD ["npm", "start"] 