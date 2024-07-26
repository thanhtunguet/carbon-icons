"use strict";

import CarbonMeta from "@carbon/icons/metadata.json" assert { type: "json" };
import pLimit from "p-limit";
import path from "path";
import { copyFile, mkdir, readdir, rename, writeFile } from "fs/promises";
import { optimize } from "svgo";
import { generateFonts } from "@twbs/fantasticon";
import { exec } from "child_process";
import { promisify } from "util";
const execPromise = promisify(exec);

init();

async function init() {
  try {
    console.log("Building optimised SVG files");
    await buildSVG();

    console.log("Converting SVG files to ttf");
    const outputDir = path.join("tool", "generated");
    await mkdir(outputDir, { recursive: true });
    await generateFonts({
      inputDir: "tool/svg/32/", // (required)
      outputDir: "tool/generated/", // (required)
      name: "CarbonFonts",
      normalize: "false",
      round: "10e12",
      fontTypes: ["ttf"],
      assetTypes: ["css", "json", "html"],
    });

    console.log("Generating IconData from ttf");
    await execPromise("dart font_generator.dart", { cwd: "tool" });

    console.log("Formatting generated dart file");
    await execPromise("dart format tool/generated/carbon_fonts.dart");

    console.log("Moving generated files to lib");
    const generatedPath = ["tool", "generated"];
    await copyFile(
      path.join(...generatedPath, "carbon_fonts.dart"),
      path.join("lib", "src", "fonts", "carbon_fonts.dart")
    );

    const generatedFiles = await readdir(path.join(...generatedPath), {
      withFileTypes: true,
    });
    await Promise.all(
      generatedFiles
        .filter((dirent) => dirent.isFile() && !dirent.name.endsWith(".dart"))
        .map((dirent) =>
          copyFile(
            path.join(...generatedPath, dirent.name),
            path.join("docs", dirent.name)
          )
        )
    );

    await copyFile(
      path.join(...generatedPath, "CarbonFonts.ttf"),
      path.join("assets", "CarbonFonts.ttf")
    );

    await rename(
      path.join("docs", "CarbonFonts.html"),
      path.join("docs", "index.html")
    );
  } catch (e) {
    console.error(e);
  }
}

async function buildSVG() {
  // Create output dir
  const outPath = path.join("tool", "svg", "32");
  try {
    mkdir(outPath, { recursive: true });
  } catch (e) {}

  // Limit concurrent writes
  const limit = pLimit(8);

  const promises = CarbonMeta.icons
    .filter((icon) => icon.sizes.includes(32))
    .map((icon) => {
      // Filter out sizes other than 32px and store the optimized svg string
      const assets = icon.assets.filter((asset) => asset.size == 32);
      const svgString = assets[0].optimized.data;
      const fileName = icon.name.replaceAll(/-+/g, "_") + ".svg";
      return limit(() => saveSVG(outPath, fileName, svgString));
    });

  await Promise.all(promises);
}

async function saveSVG(dir, fileName, svgString) {
  const destination = path.join(dir, fileName);
  const result = optimize(svgString, {
    multipass: true,
  });

  return await writeFile(destination, result.data);
}
