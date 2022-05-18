// const avatarID = process.env.NODE_ENV === "production" ? "jmuqr-yqaaa-aaaaj-qaicq-cai" : "rrkah-fqaaa-aaaaa-aaaaq-cai";
// const accessoriesID = process.env.NODE_ENV === "production" ? "po6n2-uiaaa-aaaaj-qaiua-cai" : "ryjl3-tyaaa-aaaaa-aaaba-cai";
// const invoiceID = process.env.NODE_ENV === "production" ? "if27l-eyaaa-aaaaj-qaq5a-cai" : "r7inp-6aaaa-aaaaa-aaabq-cai";
// const ledgerID = process.env.NODE_ENV === "production" ? "ryjl3-tyaaa-aaaaa-aaaba-cai" : "rkp4c-7iaaa-aaaaa-aaaca-cai";

const avatarID = "jmuqr-yqaaa-aaaaj-qaicq-cai";
const accessoriesID = "po6n2-uiaaa-aaaaj-qaiua-cai";
const invoiceID = "if27l-eyaaa-aaaaj-qaq5a-cai";
const ledgerID = "ryjl3-tyaaa-aaaaa-aaaba-cai";


const AMOUNT_MINT = { e8s: BigInt(10_000_000) };
const AMOUNT_FEE = { e8s: BigInt(10_000) };

// const HOST = process.env.NODE_ENV === "production" ? "https://mainnet.dfinity.network" : "http://127.0.0.1:8000";
const HOST = "https://mainnet.dfinity.network";

export { avatarID, accessoriesID, invoiceID, ledgerID, AMOUNT_MINT, AMOUNT_FEE, HOST };
