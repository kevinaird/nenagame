function fileToByteArray(file) {
  return new Promise((resolve, reject) => {
    try {
      let reader = new FileReader();
      let fileByteArray = [];
      reader.readAsArrayBuffer(file);
      reader.onloadend = evt => {
        if (evt.target.readyState == FileReader.DONE) {
          let arrayBuffer = evt.target.result,
            array = new Uint8Array(arrayBuffer);
          for (byte of array) {
            fileByteArray.push(byte);
          }
        }
        resolve(fileByteArray);
      };
    } catch (e) {
      reject(e);
    }
  });
}

const loadTexture = function({ filename }) {
  console.log("load texture:", filename);
  return {
    GetBytes: async function() {
      const byteArray = await fileToByteArray(filename);
      console.log("byteArray", byteArray);
      return byteArray;
    }
  };
};

module.exports = { plugin_Bytemap: { loadTexture } };
