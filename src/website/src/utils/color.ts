import type { AvatarColors, Color } from "@src/types/color";
import { suggestedColors } from "@utils/list";

export function rgbToHex(r: number, g: number, b: number): string {
  return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}

export function hexToRgb(hex: string): { r: number; g: number; b: number } {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null;
}

export function generateRandomColor(): AvatarColors {
  return {
    background: suggestedColors.background[Math.floor(Math.random() * suggestedColors.background.length)] as Color,
    skin: suggestedColors.skin[Math.floor(Math.random() * suggestedColors.skin.length)] as Color,
    hairs: suggestedColors.hairs[Math.floor(Math.random() * suggestedColors.hairs.length)] as Color,
    eyes: suggestedColors.eyes[Math.floor(Math.random() * suggestedColors.eyes.length)] as Color,
    eyebrows: suggestedColors.eyebrows[Math.floor(Math.random() * suggestedColors.eyebrows.length)] as Color,
    eyeliner: suggestedColors.eyeliner[Math.floor(Math.random() * suggestedColors.eyeliner.length)] as Color,
    clothes: suggestedColors.clothes[Math.floor(Math.random() * suggestedColors.clothes.length)] as Color,
  };
}
