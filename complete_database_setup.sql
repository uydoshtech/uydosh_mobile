-- =====================================================
-- Uydosh Database Complete Setup Script
-- Generated from database schema extraction
-- Database: uydosh-dev
-- Date: $(date)
-- =====================================================

-- Set search path
SET search_path TO public;

-- =====================================================
-- 1. CREATE SEQUENCES
-- =====================================================

CREATE SEQUENCE public.amenities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.listing_amenities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.listing_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.listings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.otp_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.regions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.subway_stations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.universities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.user_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- =====================================================
-- 2. CREATE TABLES
-- =====================================================

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);

CREATE TABLE public.amenities (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name_en character varying(100) NOT NULL,
    name_ru character varying(100) NOT NULL,
    name_uz character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ordinal integer DEFAULT 0 NOT NULL
);

CREATE TABLE public.listing_amenities (
    id integer NOT NULL,
    listing_id integer NOT NULL,
    amenity_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.listing_types (
    id integer NOT NULL,
    name_uz character varying(50) NOT NULL,
    name_ru character varying(50) NOT NULL,
    name_en character varying(50) NOT NULL,
    code character varying(20) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.listings (
    id integer NOT NULL,
    title_uz character varying(255) NOT NULL,
    title_ru character varying(255) NOT NULL,
    title_en character varying(255) NOT NULL,
    description_uz text,
    description_ru text,
    description_en text,
    price decimal(10,2) NOT NULL,
    currency character varying(3) DEFAULT 'UZS'::character varying,
    listing_type_id integer NOT NULL,
    location_id integer NOT NULL,
    owner_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.locations (
    id integer NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    region_id integer NOT NULL,
    latitude double precision,
    longitude double precision,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.otp_codes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    code character varying(6) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.regions (
    id integer NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.subway_stations (
    id integer NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    location_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.universities (
    id integer NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    location_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.user_profiles (
    id integer NOT NULL,
    user_id integer NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    phone character varying(20),
    avatar_url character varying(500),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

-- =====================================================
-- 3. CREATE INDEXES
-- =====================================================

CREATE INDEX idx_amenities_code ON public.amenities USING btree (code);
CREATE INDEX idx_listing_amenities_amenity_id ON public.listing_amenities USING btree (amenity_id);
CREATE INDEX idx_listing_amenities_listing_id ON public.listing_amenities USING btree (listing_id);
CREATE INDEX idx_locations_coordinates ON public.locations USING gist (ll_to_earth(latitude, longitude));
CREATE INDEX idx_locations_region_id ON public.locations USING btree (region_id);
CREATE INDEX idx_listings_location_id ON public.listings USING btree (location_id);
CREATE INDEX idx_listings_owner_id ON public.listings USING btree (owner_id);
CREATE INDEX idx_listings_price ON public.listings USING btree (price);
CREATE INDEX idx_otp_codes_user_id ON public.otp_codes USING btree (user_id);
CREATE INDEX idx_otp_codes_code ON public.otp_codes USING btree (code);
CREATE INDEX idx_subway_stations_location_id ON public.subway_stations USING btree (location_id);
CREATE INDEX idx_universities_location_id ON public.universities USING btree (location_id);
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles USING btree (user_id);
CREATE INDEX idx_users_email ON public.users USING btree (email);

-- =====================================================
-- 4. SET SEQUENCE OWNERSHIP
-- =====================================================

ALTER SEQUENCE public.amenities_id_seq OWNED BY public.amenities.id;
ALTER SEQUENCE public.listing_amenities_id_seq OWNED BY public.listing_amenities.id;
ALTER SEQUENCE public.listing_types_id_seq OWNED BY public.listing_types.id;
ALTER SEQUENCE public.listings_id_seq OWNED BY public.listings.id;
ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;
ALTER SEQUENCE public.otp_codes_id_seq OWNED BY public.otp_codes.id;
ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;
ALTER SEQUENCE public.subway_stations_id_seq OWNED BY public.subway_stations.id;
ALTER SEQUENCE public.universities_id_seq OWNED BY public.universities.id;
ALTER SEQUENCE public.user_profiles_id_seq OWNED BY public.user_profiles.id;
ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

-- =====================================================
-- 5. SET DEFAULT VALUES FOR ID COLUMNS
-- =====================================================

ALTER TABLE ONLY public.amenities ALTER COLUMN id SET DEFAULT nextval('public.amenities_id_seq'::regclass);
ALTER TABLE ONLY public.listing_amenities ALTER COLUMN id SET DEFAULT nextval('public.listing_amenities_id_seq'::regclass);
ALTER TABLE ONLY public.listing_types ALTER COLUMN id SET DEFAULT nextval('public.listing_types_id_seq'::regclass);
ALTER TABLE ONLY public.listings ALTER COLUMN id SET DEFAULT nextval('public.listings_id_seq'::regclass);
ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);
ALTER TABLE ONLY public.otp_codes ALTER COLUMN id SET DEFAULT nextval('public.otp_codes_id_seq'::regclass);
ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);
ALTER TABLE ONLY public.subway_stations ALTER COLUMN id SET DEFAULT nextval('public.subway_stations_id_seq'::regclass);
ALTER TABLE ONLY public.universities ALTER COLUMN id SET DEFAULT nextval('public.universities_id_seq'::regclass);
ALTER TABLE ONLY public.user_profiles ALTER COLUMN id SET DEFAULT nextval('public.user_profiles_id_seq'::regclass);
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

-- =====================================================
-- 6. ADD PRIMARY KEY CONSTRAINTS
-- =====================================================

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.listing_amenities
    ADD CONSTRAINT listing_amenities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.listing_types
    ADD CONSTRAINT listing_types_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.subway_stations
    ADD CONSTRAINT subway_stations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.universities
    ADD CONSTRAINT universities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

-- =====================================================
-- 7. ADD UNIQUE CONSTRAINTS
-- =====================================================

ALTER TABLE ONLY public.amenities
    ADD CONSTRAINT amenities_code_key UNIQUE (code);

ALTER TABLE ONLY public.listing_types
    ADD CONSTRAINT listing_types_code_key UNIQUE (code);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);

-- =====================================================
-- 8. ADD FOREIGN KEY CONSTRAINTS
-- =====================================================

ALTER TABLE ONLY public.listing_amenities
    ADD CONSTRAINT listing_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.listing_amenities
    ADD CONSTRAINT listing_amenities_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_listing_type_id_fkey FOREIGN KEY (listing_type_id) REFERENCES public.listing_types(id);

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.subway_stations
    ADD CONSTRAINT subway_stations_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.universities
    ADD CONSTRAINT universities_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

-- =====================================================
-- Script completed successfully!
-- =====================================================
