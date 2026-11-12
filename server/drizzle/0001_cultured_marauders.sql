CREATE TABLE "kitchen_users" (
	"id" text PRIMARY KEY NOT NULL,
	"username" text NOT NULL,
	"password_hash" text NOT NULL,
	"restaurant_id" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "kitchen_users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
ALTER TABLE "menu_items" ADD COLUMN "is_available" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "orders" ADD COLUMN "confirmed_at" timestamp;--> statement-breakpoint
ALTER TABLE "orders" ADD COLUMN "preparing_started_at" timestamp;--> statement-breakpoint
ALTER TABLE "orders" ADD COLUMN "ready_at" timestamp;--> statement-breakpoint
ALTER TABLE "kitchen_users" ADD CONSTRAINT "kitchen_users_restaurant_id_restaurants_id_fk" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE cascade ON UPDATE no action;