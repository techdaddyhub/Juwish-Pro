"use client";

import React, { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";

export default function SplashScreen() {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    // Show splash screen for 1.3 seconds on page entry
    const timer = setTimeout(() => {
      setVisible(false);
    }, 1300);

    return () => clearTimeout(timer);
  }, []);

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          key="binance-splash"
          initial={{ opacity: 1 }}
          exit={{ opacity: 0, scale: 1.04 }}
          transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
          className="fixed inset-0 z-[999999] flex flex-col items-center justify-center bg-[#0B0E11] select-none"
        >
          {/* Subtle Ambient Radial Glow */}
          <div className="absolute w-[420px] h-[420px] rounded-full bg-[#F0B90B]/10 blur-[120px] pointer-events-none" />

          {/* Central Logo & Icon */}
          <motion.div
            initial={{ scale: 0.85, opacity: 0, y: 10 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            transition={{ duration: 0.5, ease: "easeOut" }}
            className="relative flex flex-col items-center"
          >
            {/* Logo Container */}
            <div className="relative mb-5 flex items-center justify-center">
              <div className="relative w-20 h-20 rounded-2xl bg-[#181A20] border border-[#2B313A] flex items-center justify-center shadow-2xl shadow-[#F0B90B]/15">
                <Image
                  src="/img/logo/logo.webp"
                  alt="App Logo"
                  width={56}
                  height={56}
                  priority
                  className="object-contain"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    if (target.src.includes(".webp")) {
                      target.src = "/img/logo/logo.png";
                    } else {
                      target.src = "/placeholder-logo.png";
                    }
                  }}
                />
              </div>
            </div>

            {/* Platform Brand Name */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.2, duration: 0.4 }}
              className="flex items-center gap-2 mb-6"
            >
              <span className="text-xl font-bold tracking-tight text-[#EAECEF]">
                Juwish<span className="text-[#F0B90B]">Pro</span>
              </span>
            </motion.div>

            {/* Binance-style Golden Progress Bar */}
            <div className="w-36 h-1 bg-[#1E2329] rounded-full overflow-hidden">
              <motion.div
                initial={{ x: "-100%" }}
                animate={{ x: "100%" }}
                transition={{
                  repeat: Infinity,
                  duration: 1.1,
                  ease: "easeInOut",
                }}
                className="w-1/2 h-full bg-[#F0B90B] rounded-full shadow-[0_0_8px_#F0B90B]"
              />
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
