const IMAGE_SET = [
  ["kyouko_pc.png", "Kyouko browsing the <a href=\"/blog\">blog</a>"],
  ["mari_emacs.png", "Shoutouts to witchmacs"],
  ["keiki_hello.gif", "Keiki is happy to see you here!!"],
  ["cirno_cpp.png", "The smartest will teach you!"],
  ["chen.png", "Chen is here too!"],
];

const getRandomImg = () => { return IMAGE_SET[Math.floor(Math.random()*IMAGE_SET.length)]; };

const rollNewImage = () => {
  const [image, caption] = getRandomImg();
  const img_elem = document.getElementById("random-image");
  const caption_elem = document.getElementById("random-image-caption");

  img_elem.src = `/image/funnies/${image}`;
  caption_elem.innerHTML = caption;
};

rollNewImage();
