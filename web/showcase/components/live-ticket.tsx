"use client";

import { useEffect, useState } from "react";

const statuses = [
  { label: "Order placed", eta: "demo" },
  { label: "Confirmed", eta: "demo" },
  { label: "Preparing", eta: "demo" },
  { label: "Ready", eta: "demo" },
  { label: "Out for delivery", eta: "16 min" },
] as const;

export function LiveTicket() {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setIndex(statuses.length - 1);
      return;
    }

    const timer = window.setInterval(() => {
      setIndex((current) => {
        if (current >= statuses.length - 1) {
          window.clearInterval(timer);
          return current;
        }
        return current + 1;
      });
    }, 1200);

    return () => window.clearInterval(timer);
  }, []);

  const status = statuses[index];

  return (
    <article className="ticket" aria-label="Demo order ticket FD15784803">
      <div className="ticket__head">
        <span>Foodie</span>
        <span>Service ticket</span>
      </div>
      <div className="ticket__body">
        <div className="ticket__row">
          <span>Order</span>
          <strong>FD15784803</strong>
        </div>
        <div className="ticket__row">
          <span>Table</span>
          <strong>Demo, 2 items</strong>
        </div>
        <div className="ticket__items">Hyderabadi House</div>
        <div className="ticket__row ticket__total">
          <span>Total</span>
          <strong>₹578</strong>
        </div>
        <div className="ticket__status" aria-hidden="true">
          <span className="ticket__dot" />
          <span>{status.label}</span>
          <span className="ticket__eta">{status.eta}</span>
        </div>
        <div className="ticket__steps" aria-hidden="true">
          {Array.from({ length: 6 }, (_, step) => (
            <span
              key={step}
              className={step < index ? "is-done" : step === index ? "is-current" : undefined}
            />
          ))}
        </div>
      </div>
      <div className="ticket__foot">Demo order. Not a real purchase.</div>
      <span className="sr-only">Demo order status: out for delivery. This is a simulated order.</span>
    </article>
  );
}
