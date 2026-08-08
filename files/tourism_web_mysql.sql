-- ============================================================
-- База данных для WEB-приложения «Бронирование туров»
-- СУБД: MySQL 8.x
-- (аналог tourism_web_mssql.sql, адаптированный под MySQL)
-- ============================================================

DROP DATABASE IF EXISTS tourism_web;
CREATE DATABASE tourism_web CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tourism_web;

-- ------------------------------------------------------------
-- Справочник направлений (стран)
-- ------------------------------------------------------------
CREATE TABLE countries (
    country_id      INT AUTO_INCREMENT PRIMARY KEY,
    country_name    VARCHAR(100)  NOT NULL UNIQUE,
    flight_hours    DECIMAL(4,1)  NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник туров
-- ------------------------------------------------------------
CREATE TABLE tours (
    tour_id         INT AUTO_INCREMENT PRIMARY KEY,
    tour_name       VARCHAR(150)  NOT NULL,
    country_id      INT           NOT NULL,
    duration_days   INT           NOT NULL,
    price_per_person DECIMAL(10,2) NOT NULL,
    description     VARCHAR(500),
    CONSTRAINT fk_tours_country
        FOREIGN KEY (country_id) REFERENCES countries(country_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Таблица переменной информации: заявки на бронирование,
-- которые создаёт web-приложение
-- ------------------------------------------------------------
CREATE TABLE bookings (
    booking_id      INT AUTO_INCREMENT PRIMARY KEY,
    tour_id         INT           NOT NULL,
    client_name     VARCHAR(150)  NOT NULL,
    client_phone    VARCHAR(20)   NOT NULL,
    client_email    VARCHAR(100),
    num_people      INT           NOT NULL DEFAULT 1,
    booking_date    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(20)   NOT NULL DEFAULT 'Новая',
    CONSTRAINT fk_bookings_tour
        FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Тестовые данные
-- ------------------------------------------------------------
INSERT INTO countries (country_name, flight_hours) VALUES
('Турция', 4.0),
('Египет', 5.0),
('Италия', 3.5),
('Таиланд', 10.0);

INSERT INTO tours (tour_name, country_id, duration_days, price_per_person, description) VALUES
('Анталия All Inclusive', 1, 10, 650.00, 'Пляжный отдых 5*, всё включено'),
('Хургада: море и коралловые рифы', 2, 7, 480.00, 'Дайвинг и снорклинг'),
('Рим — вечный город', 3, 6, 720.00, 'Экскурсионный тур по историческому центру'),
('Пхукет: райский остров', 4, 12, 990.00, 'Пляжи, острова, тайский массаж');

INSERT INTO bookings (tour_id, client_name, client_phone, client_email, num_people) VALUES
(1, 'Иванов Иван', '+7 900 111-22-33', 'ivanov@mail.ru', 2);

-- ------------------------------------------------------------
-- Представление для web-приложения: список туров с названием страны
-- ------------------------------------------------------------
CREATE VIEW vw_tour_list AS
SELECT
    t.tour_id,
    t.tour_name,
    c.country_name,
    t.duration_days,
    t.price_per_person,
    t.description
FROM tours t
JOIN countries c ON t.country_id = c.country_id;
