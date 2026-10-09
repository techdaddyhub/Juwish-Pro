-- Register JuwishCoin (JWC) into Currency table
INSERT INTO `currency` (`id`, `name`, `symbol`, `precision`, `price`, `status`)
VALUES ('JWC', 'JuwishCoin', 'JWC', 8, 0.05, 1)
ON DUPLICATE KEY UPDATE `name` = 'JuwishCoin', `status` = 1;

-- Register JuwishCoin (JWC) BEP-20 into Ecosystem Token table on BSC
INSERT INTO `ecosystem_token` (
  `id`, `name`, `currency`, `chain`, `network`, `type`, `contract`, `contractType`, `decimals`, `status`, `precision`, `icon`, `createdAt`, `updatedAt`
) VALUES (
  UUID(), 'JuwishCoin', 'JWC', 'BSC', 'mainnet', 'BEP20',
  '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99', 'NO_PERMIT', 18, 1, 8,
  '/img/crypto/jwc.webp', NOW(), NOW()
)
ON DUPLICATE KEY UPDATE
  `contract` = '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99',
  `status` = 1,
  `updatedAt` = NOW();

