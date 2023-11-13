self.importScripts("nano-pow.js");
self.importScripts("index.js");

Module.onRuntimeInitialized = NanoPow.workerInitialize;

onmessage = function (ev) {
  const { hash, threshold } = ev.data;

  const proofOfWork = NanoPow._getProofOfWork(hash, threshold);

  if (proofOfWork !== "0000000000000000") {
    powFound(hash, threshold, proofOfWork);
  } else {
    powNotFound();
  }
};

function powNotFound() {
  return postMessage({ message: "failed" });
}

function powFound(hash, threshold, proofOfWork) {
  return postMessage({ message: "success", hash, threshold, proofOfWork });
}
