import fs from "fs/promises";
import { variants } from "@catppuccin/palette";
import { defineConfig, presetUno } from "unocss";

const generatePalette = () => {
  const colors = {};

  Object.keys(variants.mocha).forEach((colorName) => {
    const sanitizedName = colorName
      .replace("0", "zero")
      .replace("1", "one")
      .replace("2", "two");
    colors[sanitizedName] = variants.mocha[colorName].hex;
  });

  return colors;
};

const catppuccinColors = generatePalette()

export default defineConfig({
  preflights: [
    {
      layer: "reset",
      getCSS: () =>
        fs.readFile("node_modules/@unocss/reset/tailwind.css", "utf-8"),
    },
    {
      layer: "mycss",
      getCSS: ({ theme }) => `
    body {
      font-family: 'Recursive', monospace;
      font-variation-settings: 'MONO' 1;
    }
    #menu-toggle:checked + #menu {
		  display: block;
		}
    a {
      text-decoration: underline dotted;
      color: ${theme.colors.ctp.rosewater};
    }
    a:hover {
      color: ${theme.colors.ctp.mauve};
    }
    `,
    },
  ],
  // accent color is dynamically generated 
  safelist: Object.keys(catppuccinColors).flatMap((key: string) => [`text-ctp-${key}`, `b-ctp-${key}`]),
  presets: [presetUno()],
  rules: [
    ["font-casual", { "font-variation-settings": "'CASL' 1;" }],
    ["font-mono-casual", { "font-variation-settings": "'MONO' 1, 'CASL' 1;" }],
  ],
  shortcuts: {
    btn: "border-1 border-solid rounded border-ctp-mauve flex flex-row hover:border-ctp-sky hover:text-ctp-rosewater m-2",
    // link: "underline text-ctp-rosewater"
  },
  theme: {
    colors: {
      ctp: generatePalette(),
    },
  },
  layers: {
    reset: -1,
    mycss: 0.5,
    shortcuts: 0,
    components: 1,
    default: 2,
    utilities: 3,
  },
});
