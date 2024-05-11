import { useEffect, useMemo, useState } from "react";
import Particles, { initParticlesEngine } from "@tsparticles/react";
import { loadConfettiPreset } from "@tsparticles/preset-confetti"
import {
  type Container,
  type ISourceOptions,
  MoveDirection,
  OutMode,
} from "@tsparticles/engine";
// import { loadAll } from "@tsparticles/all"; // if you are going to use `loadAll`, install the "@tsparticles/all" package too.
// import { loadFull } from "tsparticles"; // if you are going to use `loadFull`, install the "tsparticles" package too.
import { loadSlim } from "@tsparticles/slim"; // if you are going to use `loadSlim`, install the "@tsparticles/slim" package too.
import { Button } from "antd";
import { confetti } from "@tsparticles/confetti";
// import { loadBasic } from "@tsparticles/basic"; // if you are going to use `loadBasic`, install the "@tsparticles/basic" package too.

const ParticlesDemo = () => {
  const [init, setInit] = useState(false);

  useEffect(() => {
    initParticlesEngine(async (engine) => {
      // you can initiate the tsParticles instance (engine) here, adding custom shapes or presets
      // this loads the tsparticles package bundle, it's the easiest method for getting everything ready
      // starting from v2 you can add only the features you need reducing the bundle size
      //await loadAll(engine);
      //await loadFull(engine);
      await loadConfettiPreset(engine);
      //await loadBasic(engine);
    }).then(() => {
      setInit(true);
    });
  }, []);

  function clickHandler() {
    confetti("tsparticles", {
      angle: 90,
      count: 25,
      position: { x: 50, y: 50 },
      spread: 90,
      startVelocity: 60,
      decay: 0.9,
      gravity: 1,
      drift: 0,
      ticks: 200,
      colors: ["#fff", "#f00"],
      shapes: ["square", "circle"],
      scalar: 1,
      zIndex: 2000,
      disableForReducedMotion: true
    });

  }

  if (init) {
    return (
      <>
        <Button onClick={clickHandler}>Click</Button>
        <Particles
          id="tsparticles"
          options={{
            preset: "confetti"
          }}
        />
      </>
    )
  }

  return <></>;
};

export default ParticlesDemo


// import { useEffect, useMemo, useState } from "react";

// import {
//   type Container,
//   type ISourceOptions,
//   MoveDirection,
//   OutMode,
//   tsParticles
// } from "@tsparticles/engine";


// // import { loadAll } from "@tsparticles/all"; // if you are going to use `loadAll`, install the "@tsparticles/all" package too.
// // import { loadFull } from "tsparticles"; // if you are going to use `loadFull`, install the "tsparticles" package too.
// import { loadSlim } from "@tsparticles/slim"; // if you are going to use `loadSlim`, install the "@tsparticles/slim" package too.
// // import { loadBasic } from "@tsparticles/basic"; // if you are going to use `loadBasic`, install the "@tsparticles/basic" package too.
// // import { particleOptions } from "./particle"
// import { loadPolygonMaskPlugin } from "@tsparticles/plugin-polygon-mask";
// import { loadPolygonShape } from "@tsparticles/shape-polygon";
// import * as configs from "@tsparticles/configs"; // not needed with CDN

// const ParticlesDemo = () => {

//   async function setup() {
//     await loadPolygonMaskPlugin(tsParticles);
//     // await loadPolygonShape(tsParticles);
//     await loadSlim(tsParticles)

//     return await tsParticles.load({
//       id: "tsparticles",
//       options: configs.default.polygonMask
//     })

//   }

//   useEffect(() => {
//     setup().then(c => console.log(c))
//   }, [])

//   return <div id="tsparticles"></div>
// };

// export default ParticlesDemo






