import { ComponentSingle } from "./component";

export type Slots = {
  Hat: Accessory | null;
  Face: Accessory | null;
  Eyes: Accessory | null;
  Body: Accessory | null;
  Misc: Accessory | null;
};

export type Accessory = {
  name: string;
  description: string;
  slot: string;
  recipe: string[];
  components: ComponentSingle[];
};
