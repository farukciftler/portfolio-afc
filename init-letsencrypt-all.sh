#!/bin/bash

# Tüm domainler için Let's Encrypt sertifika yenileme scripti
# nginx config dosyalarından domainleri otomatik olarak tarar

rsa_key_size=4096
data_path="./nginx/certbot"
email="ciftlerabdullah@gmail.com"
config_dir="./nginx/conf.d"

# Config dosyalarından domainleri topla
echo "### Scanning nginx config files for domains..."
domains=()

# Tüm .conf dosyalarını tara
for conf_file in "$config_dir"/*.conf; do
    if [ -f "$conf_file" ]; then
        echo "Processing $conf_file..."

        # server_name satırlarını çıkar (hem HTTP hem HTTPS için)
        server_names=$(grep -h "server_name" "$conf_file" | sed 's/.*server_name//' | sed 's/;//' | sed 's/^[[:space:]]*//' | sort | uniq)

        while IFS= read -r line; do
            if [ ! -z "$line" ]; then
                # Çoklu domain varsa ayır (boşlukla ayrılmış)
                IFS=' ' read -ra DOMAIN_ARRAY <<< "$line"
                for domain in "${DOMAIN_ARRAY[@]}"; do
                    # www. prefix'i varsa ana domain'i de ekle
                    if [[ $domain == www.* ]]; then
                        base_domain=${domain#www.}
                        if [[ ! " ${domains[@]} " =~ " ${base_domain} " ]]; then
                            domains+=("$base_domain")
                        fi
                        if [[ ! " ${domains[@]} " =~ " ${domain} " ]]; then
                            domains+=("$domain")
                        fi
                    else
                        if [[ ! " ${domains[@]} " =~ " ${domain} " ]]; then
                            domains+=("$domain")
                        fi
                    fi
                done
            fi
        done <<< "$server_names"
    fi
done

# Duplicate'ları kaldır ve sırala
domains=($(printf '%s\n' "${domains[@]}" | sort | uniq))

echo "### Found domains: ${domains[*]}"

# Her domain için sertifika işlemini gerçekleştir
for domain in "${domains[@]}"; do
    echo "=== Processing domain: $domain ==="

    # Domain için gerekli dosyaları kontrol et
    if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
        echo "### Downloading recommended TLS parameters ..."
        mkdir -p "$data_path/conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
        echo
    fi

    echo "### Creating dummy certificate for $domain ..."
    path="/etc/letsencrypt/live/$domain"
    mkdir -p "$data_path/conf/live/$domain"
    docker compose run --rm --entrypoint "\
      openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=$domain'" certbot
    echo

    echo "### Starting nginx ..."
    docker compose up --force-recreate -d nginx
    echo

    echo "### Deleting dummy certificate for $domain ..."
    docker compose run --rm --entrypoint "\
      rm -Rf /etc/letsencrypt/live/$domain && \
      rm -Rf /etc/letsencrypt/archive/$domain && \
      rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
    echo

    echo "### Requesting Let's Encrypt certificate for $domain ..."
    docker compose run --rm --entrypoint "\
      certbot certonly --webroot -w /var/www/certbot \
        -d $domain \
        --email $email \
        --rsa-key-size $rsa_key_size \
        --agree-tos \
        --force-renewal" certbot
    echo

done

echo "### Reloading nginx ..."
docker compose exec nginx nginx -s reload
echo

echo "### All certificates processed successfully!"
