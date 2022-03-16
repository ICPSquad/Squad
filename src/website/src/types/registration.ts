export type RegistrationObject = {
  email?: string;
  discord?: string;
  twitter?: string;
  wallet: string;
};

export type FormObject = {
  email?: string;
  discord?: string;
  twitter?: string;
};

export type InvoiceInfo = {
  id: Number;
  account: string;
  amount: Number;
  expiration: string; //TODO how to deal with this type?
};
