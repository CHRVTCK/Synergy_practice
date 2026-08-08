-- ============================================================
-- База данных «Туризм»
-- Кейс-задача №3
--
-- Состав:
--   Таблицы-справочники (4):
--     1. countries   — справочник стран/направлений
--     2. tour_types  — справочник видов туров
--     3. hotels      — справочник отелей
--     4. clients     — справочник клиентов
--   Таблица переменной информации (1):
--     5. orders      — заказы туров (ссылается на все справочники)
-- ============================================================

DROP DATABASE IF EXISTS tourism;
CREATE DATABASE tourism CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tourism;

-- ------------------------------------------------------------
-- Справочник 1: Страны (направления)
-- ------------------------------------------------------------
CREATE TABLE countries (
    country_id      INT AUTO_INCREMENT PRIMARY KEY,
    country_name    VARCHAR(100) NOT NULL UNIQUE,
    visa_required   BOOLEAN      NOT NULL DEFAULT FALSE,
    flight_hours    DECIMAL(4,1) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник 2: Виды туров
-- ------------------------------------------------------------
CREATE TABLE tour_types (
    tour_type_id    INT AUTO_INCREMENT PRIMARY KEY,
    type_name       VARCHAR(50)  NOT NULL UNIQUE,   -- пляжный, экскурсионный, горнолыжный и т.д.
    description     VARCHAR(255)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник 3: Отели
-- ------------------------------------------------------------
CREATE TABLE hotels (
    hotel_id        INT AUTO_INCREMENT PRIMARY KEY,
    hotel_name      VARCHAR(150) NOT NULL,
    stars           TINYINT      NOT NULL CHECK (stars BETWEEN 1 AND 5),
    country_id      INT          NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_hotels_country
        FOREIGN KEY (country_id) REFERENCES countries(country_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник 4: Клиенты
-- ------------------------------------------------------------
CREATE TABLE clients (
    client_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    phone           VARCHAR(20)  NOT NULL,
    email           VARCHAR(100),
    passport_number VARCHAR(20)  NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Таблица переменной информации: Заказы туров
-- Ссылается на все 4 справочника через внешние ключи
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    client_id       INT           NOT NULL,
    country_id      INT           NOT NULL,
    tour_type_id    INT           NOT NULL,
    hotel_id        INT           NOT NULL,
    start_date      DATE          NOT NULL,
    end_date        DATE          NOT NULL,
    num_people      INT           NOT NULL DEFAULT 1,
    total_price     DECIMAL(10,2) NOT NULL,
    order_status    ENUM('Оформлен','Оплачен','Отменён','Завершён')
                        NOT NULL DEFAULT 'Оформлен',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_client
        FOREIGN KEY (client_id) REFERENCES clients(client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orders_country
        FOREIGN KEY (country_id) REFERENCES countries(country_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orders_tour_type
        FOREIGN KEY (tour_type_id) REFERENCES tour_types(tour_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orders_hotel
        FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT chk_orders_dates CHECK (end_date > start_date)
) ENGINE=InnoDB;

-- ============================================================
-- Тестовые данные
-- ============================================================

INSERT INTO countries (country_name, visa_required, flight_hours) VALUES
('Турция',   FALSE, 4.0),
('Египет',   FALSE, 5.0),
('Италия',   TRUE,  3.5),
('Таиланд',  FALSE, 10.0);

INSERT INTO tour_types (type_name, description) VALUES
('Пляжный',       'Отдых на море, солнце и пляж'),
('Экскурсионный', 'Осмотр достопримечательностей'),
('Горнолыжный',   'Катание на лыжах и сноуборде'),
('Оздоровительный','SPA и лечебные программы');

INSERT INTO hotels (hotel_name, stars, country_id, price_per_night) VALUES
('Sunny Resort',      5, 1, 120.00),
('Red Sea Paradise',  4, 2, 90.00),
('Roma Palace',       4, 3, 150.00),
('Bangkok Garden',    3, 4, 60.00);

INSERT INTO clients (full_name, phone, email, passport_number) VALUES
('Иванов Иван Иванович',    '+7 900 111-22-33', 'ivanov@mail.ru',   'AB1234567'),
('Петрова Анна Сергеевна',  '+7 900 444-55-66', 'petrova@mail.ru',  'AB7654321'),
('Сидоров Пётр Николаевич', '+7 900 777-88-99', 'sidorov@mail.ru',  'AB1112223');

INSERT INTO orders (client_id, country_id, tour_type_id, hotel_id, start_date, end_date, num_people, total_price, order_status) VALUES
(1, 1, 1, 1, '2026-08-10', '2026-08-20', 2, 2400.00, 'Оплачен'),
(2, 3, 2, 3, '2026-09-01', '2026-09-08', 1, 1200.00, 'Оформлен'),
(3, 4, 1, 4, '2026-10-05', '2026-10-15', 3, 1800.00, 'Оформлен');

-- ============================================================
-- Примеры запросов для проверки связей
-- ============================================================

-- Полная информация по заказам (JOIN всех таблиц)
SELECT
    o.order_id,
    c.full_name        AS client,
    co.country_name     AS country,
    tt.type_name        AS tour_type,
    h.hotel_name         AS hotel,
    o.start_date,
    o.end_date,
    o.num_people,
    o.total_price,
    o.order_status
FROM orders o
JOIN clients     c  ON o.client_id    = c.client_id
JOIN countries   co ON o.country_id   = co.country_id
JOIN tour_types  tt ON o.tour_type_id = tt.tour_type_id
JOIN hotels      h  ON o.hotel_id     = h.hotel_id
ORDER BY o.order_id;
