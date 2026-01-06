import fs from "fs/promises";
import { flavors } from "@catppuccin/palette";
import { defineConfig, presetUno, presetIcons } from "unocss";

const generatePalette = (): { [key: string]: string } => {
  const colors: { [key: string]: string } = {};

  Object.keys(flavors.mocha.colors).forEach((colorName) => {
    const sanitizedName = colorName
      .replace("0", "zero")
      .replace("1", "one")
      .replace("2", "two");
    colors[sanitizedName] = flavors.mocha.colors[colorName].hex;
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
      getCSS: () => `
    body {
      font-family: 'Recursive', monospace;
      font-variation-settings: 'MONO' 1;
    }
    #menu-toggle:checked + #menu {
		  display: block;
		}
    a {
      text-decoration: underline dotted;
      color: ${catppuccinColors.rosewater};
    }
    a:hover {
      color: ${catppuccinColors.mauve};
      cursor: pointer;
    }

    /* width */
    ::-webkit-scrollbar {
        width: 10px;
    }
    /* Track */
    ::-webkit-scrollbar-track {
        background: ${catppuccinColors.crust};
        border-radius: 5px;
    }
    /* Handle */
    ::-webkit-scrollbar-thumb {
        background: ${catppuccinColors.mantle};
        border: 1px solid transparent;
        border-color: ${catppuccinColors.rosewater};
        border-radius: 5px;
    }
    /* Handle on hover */
    ::-webkit-scrollbar-thumb:hover {
        background: ${catppuccinColors.roswater};
    }


    /* loading animation */
    .lds-dual-ring {
      display: inline-block;
      width: 80px;
      height: 80px;
    }
    .lds-dual-ring:after {
      content: " ";
      display: block;
      width: 64px;
      height: 64px;
      margin: 8px;
      border-radius: 50%;
      border: 6px solid #fff;
      border-color: #fff transparent #fff transparent;
      animation: lds-dual-ring 1.2s linear infinite;
    }
    @keyframes lds-dual-ring {
      0% {
        transform: rotate(0deg);
      }
      100% {
        transform: rotate(360deg);
      }
    }
    `,
    },
  ],
  // accent color is dynamically generated so pre-populate the styles
  safelist: Object.keys(catppuccinColors).flatMap((key: string) => [`text-ctp-${key}`, `b-ctp-${key}`, `bg-ctp-${key}`]),
  presets: [presetUno(), presetIcons()],
  rules: [
    ["font-casual", { "font-variation-settings": "'CASL' 1;" }],
    ["font-mono-casual", { "font-variation-settings": "'MONO' 1, 'CASL' 1;" }],
  ],
  shortcuts: {
    link: "cursor-pointer text-ctp-rosewater hover:text-ctp-mauve",
  },
  theme: {
    colors: {
      ctp: catppuccinColors,
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
