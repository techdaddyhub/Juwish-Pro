"use client";

import React, { useState } from "react";
import { ExternalLink, Copy, Check, Sparkles, ArrowUpRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

interface PancakeSwapDepositCardProps {
  tokenSymbol?: string;
  contractAddress?: string;
  depositAddress?: string;
}

export default function PancakeSwapDepositCard({
  tokenSymbol = "JWC",
  contractAddress = "0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99",
  depositAddress = "",
}: PancakeSwapDepositCardProps) {
  const [copiedContract, setCopiedContract] = useState(false);
  const [copiedDeposit, setCopiedDeposit] = useState(false);

  const pancakeSwapUrl = `https://pancakeswap.finance/swap?outputCurrency=${contractAddress}&chainId=56`;

  const copyToClipboard = (text: string, type: "contract" | "deposit") => {
    if (!text) return;
    navigator.clipboard.writeText(text);
    if (type === "contract") {
      setCopiedContract(true);
      setTimeout(() => setCopiedContract(false), 2000);
      toast.success("JuwishCoin BSC Contract Address copied!");
    } else {
      setCopiedDeposit(true);
      setTimeout(() => setCopiedDeposit(false), 2000);
      toast.success("Deposit Address copied!");
    }
  };

  return (
    <div className="relative overflow-hidden rounded-2xl border border-[#F0B90B]/30 bg-gradient-to-br from-[#181A20] via-[#1E2329] to-[#0B0E11] p-6 shadow-xl">
      {/* Background Accent Glow */}
      <div className="absolute -top-12 -right-12 h-44 w-44 rounded-full bg-[#F0B90B]/10 blur-3xl pointer-events-none" />

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[#2B313A]">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-[#F0B90B]/10 border border-[#F0B90B]/40 flex items-center justify-center text-[#F0B90B] font-bold text-lg shadow-md shadow-[#F0B90B]/10">
            🥞
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="font-semibold text-base text-[#EAECEF]">
                Deposit with JuwishCoin ({tokenSymbol})
              </h3>
              <span className="inline-flex items-center gap-1 rounded-full bg-[#F0B90B]/15 px-2.5 py-0.5 text-xs font-semibold text-[#F0B90B]">
                <Sparkles className="w-3 h-3" /> PancakeSwap Direct
              </span>
            </div>
            <p className="text-xs text-[#848E9C]">
              Acquire JuwishCoin on PancakeSwap DEX and deposit directly to your wallet on BNB Smart Chain.
            </p>
          </div>
        </div>

        {/* Primary CTA: Open PancakeSwap */}
        <Button
          onClick={() => window.open(pancakeSwapUrl, "_blank", "noopener,noreferrer")}
          className="bg-[#F0B90B] hover:bg-[#FCD535] text-[#181A20] font-semibold text-sm px-4 py-2.5 rounded-xl shadow-lg shadow-[#F0B90B]/20 flex items-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98]"
        >
          <span>Swap on PancakeSwap</span>
          <ArrowUpRight className="w-4 h-4" />
        </Button>
      </div>

      {/* Details Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-5">
        {/* Verified BEP-20 Contract */}
        <div className="rounded-xl bg-[#0B0E11]/80 border border-[#2B313A] p-3.5 space-y-1.5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-[#848E9C]">
              Official BSC Contract (BEP-20)
            </span>
            <span className="text-[11px] font-mono text-[#0ECB81]">Chain ID: 56</span>
          </div>
          <div className="flex items-center justify-between gap-2">
            <span className="font-mono text-xs text-[#EAECEF] truncate">
              {contractAddress}
            </span>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => copyToClipboard(contractAddress, "contract")}
              className="h-7 w-7 p-0 text-[#848E9C] hover:text-[#F0B90B] hover:bg-[#2B313A]"
            >
              {copiedContract ? <Check className="w-3.5 h-3.5 text-[#0ECB81]" /> : <Copy className="w-3.5 h-3.5" />}
            </Button>
          </div>
        </div>

        {/* Quick Instructions */}
        <div className="rounded-xl bg-[#0B0E11]/80 border border-[#2B313A] p-3.5 space-y-1 text-xs text-[#848E9C]">
          <span className="font-medium text-[#EAECEF] block">Quick Deposit Steps:</span>
          <ol className="list-decimal list-inside space-y-0.5">
            <li>Open PancakeSwap & swap BNB / USDT for <strong className="text-[#F0B90B]">{tokenSymbol}</strong>.</li>
            <li>Send the purchased tokens to your platform deposit address above.</li>
            <li>Balance is credited automatically within 15 BSC block confirmations.</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
