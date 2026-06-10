# PHP Development Workspace

โปรเจคนี้ประกอบด้วย Docker workspace สำหรับการพัฒนา ที่มี PHP CLI เวอร์ชัน 7.4, 8.1 และ 8.4 อยู่ใน container เดียวกัน สำหรับใช้งานกับ Laravel และ PHP projects

**หมายเหตุ**: Workspace นี้มีทั้ง CLI และ PHP-FPM services แยกตามเวอร์ชัน (7.4 / 8.1 / 8.4) เพื่อให้ใช้กับ Nginx/Apache ได้ตามต้องการ

## โครงสร้างไฟล์

```
.
├── Dockerfile.workspace              # Dockerfile สำหรับ Development Workspace
├── php.ini                            # PHP configuration สำหรับ Laravel
├── docker-entrypoint.sh              # Entrypoint script สำหรับตั้งค่า permissions
├── docker-compose.yml                # Docker Compose configuration
├── .gitignore                        # Git ignore rules
├── .gitattributes                    # Git attributes
```

## Git Repository

โปรเจคนี้มี Git repository อยู่แล้ว สามารถใช้งานได้ทันที:

```bash
# ตรวจสอบสถานะ
git status

# ดู commit history
git log

# สร้าง branch ใหม่
git checkout -b feature/your-feature

# เพิ่ม remote repository (ถ้าต้องการ)
git remote add origin <your-repo-url>
git push -u origin master
```

**หมายเหตุ**: โฟลเดอร์ `php_project/` ถูก ignore โดย Git เพื่อไม่ให้ commit โค้ดโปรเจคเข้าไปใน repository นี้

## การใช้งาน

### 1. Build และ Start Containers

```bash
docker-compose up -d --build
```

**หมายเหตุ**: Workspace นี้ใช้สำหรับการพัฒนาเท่านั้น (PHP CLI) สำหรับ PHP-FPM ให้ใช้ container แยก

### 2. ตรวจสอบสถานะ Containers

```bash
docker-compose ps
```

### 3. ดู Logs

```bash
# ดู logs ของ workspace
docker-compose logs workspace
```

### 4. หยุด Containers

```bash
docker-compose down
```


## PHP Extensions ที่ติดตั้ง

Extensions ที่ติดตั้งสำหรับ Laravel 10:

### Extensions ที่จำเป็นสำหรับ Laravel 10:
- **pdo_mysql** - สำหรับเชื่อมต่อ MySQL/MariaDB
- **mbstring** - สำหรับจัดการ multibyte strings (จำเป็น)
- **xml** - สำหรับ XML processing (จำเป็น)
- **dom** - สำหรับ DOM manipulation (จำเป็น)
- **fileinfo** - สำหรับตรวจสอบประเภทไฟล์ (จำเป็น)
- **tokenizer** - สำหรับ Laravel Blade templating (จำเป็น)
- **bcmath** - สำหรับการคำนวณตัวเลขความแม่นยำสูง (จำเป็น)
- **curl** - สำหรับ HTTP requests (จำเป็น)
- **json** - สำหรับ JSON processing (มากับ php-common)
- **openssl** - สำหรับ encryption (มากับ php-common)
- **pcre** - สำหรับ regular expressions (มากับ php-common)
- **ctype** - สำหรับ character type checking (มากับ php-common)

### Extensions เพิ่มเติม:
- **gd** - สำหรับจัดการรูปภาพ
- **zip** - สำหรับจัดการไฟล์ ZIP (จำเป็นสำหรับ Composer)
- **intl** - สำหรับ internationalization (จำเป็นสำหรับ Laravel localization)
- **opcache** - สำหรับเพิ่มประสิทธิภาพการทำงาน
- **exif** - สำหรับจัดการข้อมูล EXIF จากรูปภาพ

**หมายเหตุ**: Laravel 10 ต้องการ PHP >= 8.1 ดังนั้น workspace นี้จึงมี PHP 8.1 และ 8.4 ให้เลือกใช้งาน ส่วน PHP 7.4 เหมาะกับโปรเจกต์เก่าที่ต้องการเวอร์ชันเดิม

## การทดสอบ

สร้างไฟล์ใน `php_project/index.php` เพื่อทดสอบ:

```php
<?php
phpinfo();
?>
```

## การตรวจสอบ PHP Version

```bash
# ตรวจสอบ PHP 7.4
# ตรวจสอบ PHP 8.1
# ตรวจสอบ PHP 8.4

docker-compose exec workspace php7.4 -v
docker-compose exec workspace php8.1 -v
docker-compose exec workspace php -v
```

## การใช้งานกับ Laravel

### Laravel Version Support

- **Laravel 10**: ต้องการ PHP >= 8.1 (รองรับ PHP 8.1 และ 8.4) ✅
- **Laravel 9**: ต้องการ PHP >= 8.0 (รองรับ PHP 8.1 และ 8.4) ✅
- **Laravel 8**: ต้องการ PHP >= 7.3 (รองรับ PHP 7.4, 8.1 และ 8.4) ✅

### 1. ติดตั้ง Laravel Project

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# สร้าง Laravel 10 project ใหม่ (ใช้ PHP 8.4)
composer create-project laravel/laravel:^10.0 /var/www/php_project

# หรือสร้าง Laravel 9 project
composer create-project laravel/laravel:^9.0 /var/www/php_project

# หรือ clone project ที่มีอยู่แล้ว
git clone <your-repo> /var/www/php_project
```

### 2. ตั้งค่า Permissions

ถ้าต้องการตั้งค่า permissions ด้วยตนเอง (สำหรับ Laravel):

```bash
docker-compose exec workspace chown -R www-data:www-data /var/www/php_project/storage
docker-compose exec workspace chown -R www-data:www-data /var/www/php_project/bootstrap/cache
docker-compose exec workspace chmod -R 775 /var/www/php_project/storage
docker-compose exec workspace chmod -R 775 /var/www/php_project/bootstrap/cache
```

### 3. ติดตั้ง Dependencies

```bash
docker-compose exec workspace composer install
```

### 4. สร้าง .env File และ Generate Key

```bash
docker-compose exec workspace cp .env.example .env
docker-compose exec workspace php artisan key:generate
```

### 5. รัน Migrations

```bash
docker-compose exec workspace php artisan migrate
```

### 6. ตัวอย่าง Nginx Configuration สำหรับ Laravel

```nginx
server {
    listen 80;
    server_name laravel.test;
    root /var/www/php_project/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass <php-fpm-container>:9000;  # ใช้ PHP-FPM container แยก
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**หมายเหตุสำคัญ**: 
- ใช้ `root /var/www/php_project/public;` ไม่ใช่ `/var/www/php_project` เพราะ Laravel ใช้โฟลเดอร์ `public` เป็น document root
- ต้องมี `try_files` directive เพื่อให้ Laravel routing ทำงานได้ถูกต้อง

### 7. ตรวจสอบ PHP Extensions ที่ติดตั้ง

```bash
# ตรวจสอบ PHP 7.4 extensions
docker-compose exec workspace php7.4 -m

# ตรวจสอบ PHP 8.4 extensions
docker-compose exec workspace php -m
```

### 8. ตรวจสอบ Laravel Requirements

```bash
docker-compose exec workspace php artisan about
```

## Development Workspace

Workspace container สำหรับการพัฒนา ที่มีทั้ง PHP 7.4, 8.1 และ 8.4 อยู่ใน container เดียวกัน

### 1. เข้าใช้งาน Workspace

```bash
# เข้าใช้งาน workspace container
docker-compose exec workspace bash

# หรือเข้าใช้งานแบบ interactive
docker-compose run --rm workspace bash
```

### 2. การสลับ PHP Version

ภายใน workspace container คุณสามารถใช้ PHP หลายเวอร์ชันได้:

```bash
# ใช้ PHP 7.4
php74 -v
/usr/bin/php7.4 -v

# ใช้ PHP 8.1
php81 -v
/usr/bin/php8.1 -v

# ใช้ PHP 8.4
php -v
php84 -v
/usr/bin/php8.4 -v

# สลับ default PHP version
php74  # สลับเป็น PHP 7.4
php81  # สลับเป็น PHP 8.1
php84  # สลับเป็น PHP 8.4
```

### 3. ตรวจสอบ PHP Version ที่ติดตั้ง

```bash
# ตรวจสอบ PHP 7.4
docker-compose exec workspace php7.4 -v

# ตรวจสอบ PHP 8.4
docker-compose exec workspace php -v

# ตรวจสอบ PHP extensions
docker-compose exec workspace php -m
```

### 4. ใช้งาน Composer

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# ติดตั้ง dependencies
composer install

# สร้าง Laravel project ใหม่
composer create-project laravel/laravel .

# ใช้ PHP version เฉพาะกับ Composer
php7.4 /usr/bin/composer install
php8.1 /usr/bin/composer install
php8.4 /usr/bin/composer install
```

### 5. ใช้งานกับ Laravel

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# ติดตั้ง dependencies
composer install

# สร้าง .env file
cp .env.example .env

# Generate application key (ใช้ PHP version ที่ต้องการ)
php artisan key:generate

# รัน migrations
php artisan migrate

# รัน Laravel commands อื่นๆ
php artisan route:list
php artisan tinker
```

### 6.1 PHP-FPM Services

โปรเจคนี้มี PHP-FPM แยกตามเวอร์ชันให้พร้อมใช้งาน:

- `php74-fpm` → PHP-FPM 7.4
- `php81-fpm` → PHP-FPM 8.1
- `php84-fpm` → PHP-FPM 8.4

#### วิธีเริ่มใช้งาน FPM

```bash
docker-compose up -d --build php74-fpm php81-fpm php84-fpm
```

#### ตรวจสอบสถานะ

```bash
docker-compose ps
```

#### ดู log ของ service

```bash
docker-compose logs -f php84-fpm
```

#### ทดสอบว่า FPM ฟังพอร์ตอยู่

ใน compose นี้แต่ละ service expose ที่ `9000` ภายใน network เดียวกัน ดังนั้น Nginx/Apache container ต้องเชื่อมต่อผ่าน service name เช่น:

- `php74-fpm:9000`
- `php81-fpm:9000`
- `php84-fpm:9000`

#### ตัวอย่าง Nginx config

```nginx
server {
    listen 80;
    server_name laravel.test;
    root /var/www/php_project/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php84-fpm:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

#### หมายเหตุสำคัญ

- ถ้าจะใช้ PHP 7.4 ให้เปลี่ยน `fastcgi_pass` เป็น `php74-fpm:9000`
- ถ้าจะใช้ PHP 8.1 ให้เปลี่ยนเป็น `php81-fpm:9000`
- ถ้าจะใช้ PHP 8.4 ให้ใช้ `php84-fpm:9000`
- Nginx ต้องอยู่ใน Docker network เดียวกับ service เหล่านี้ หรือใช้ external network ร่วมกัน


Workspace container มี volume mapping ดังนี้:

- `../php_project` → `/var/www/php_project` - โฟลเดอร์ php_project ที่อยู่ระดับเดียวกันกับ php_env

**ตัวอย่างการใช้งาน:**

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# ใช้งานโปรเจคใน php_project (default working directory)
cd /var/www/php_project
# หรือ
cd .
```

### 8. หมายเหตุ

- โฟลเดอร์ `php_project` (ระดับเดียวกันกับ php_env) จะถูก map ไปที่ `/var/www/php_project`
- Default working directory คือ `/var/www/php_project`
- Default PHP version คือ 8.4
- สามารถใช้ PHP หลายเวอร์ชันพร้อมกันได้โดยระบุ path เต็ม
- Workspace นี้ใช้สำหรับการพัฒนาเท่านั้น (PHP CLI) สำหรับ PHP-FPM ให้ใช้ container แยก
- ถ้าต้องการเข้าใช้งาน container แบบ interactive ให้ใช้ `docker-compose exec workspace bash`

