NanoPow = {
  THRESHOLD__SEND_CHANGE: "fffffff800000000", // avg > 25secs on my PC
  THRESHOLD__OPEN_RECEIVE: "fffffe0000000000", // avg < 2.5secs on my PC

  workerInitialize() {
    C_getProofOfWork = (hash, threshold) => {
      return Module.ccall(
        "getProofOfWork",
        "string",
        ["string", "string"],
        [hash, threshold]
      );
    };

    postMessage({ message: "ready" });
  },

  _getProofOfWork: (hash, threshold) => C_getProofOfWork(hash, threshold),

  async getProofOfWork({ hash, threshold }) {
    return NanoPow.getProofOfWorkMultiThreaded(
      { hash, threshold },
      { workers: 1 }
    );
  },

  getProofOfWorkMultiThreaded: async function (
    { hash, threshold },
    options = {}
  ) {
    return new Promise((resolve) => {
      const workers = getPowWorkers(options.workers, options.workerScriptPath);
      if (hash.length == 64) {
        for (let worker of workers) {
          worker.onmessage = (e) => {
            const { message, ...result } = e.data;
            switch (message) {
              case "ready":
                worker.postMessage({
                  hash,
                  threshold: threshold,
                });
                break;
              case "failed":
                worker.postMessage({
                  hash,
                  threshold: threshold,
                });
                break;
              case "success":
                terminateWorkers(workers);
                resolve(result.proofOfWork);
            }
          };
        }
      }
    });
  },
};

// multithreaded capability

function getPowWorkers(
  threads = self.navigator.hardwareConcurrency - 1,
  workerScriptPath = ""
) {
  const workers = [];
  for (let i = 0; i < threads; i++) {
    workers[i] = new Worker(workerScriptPath || "./nano-pow/thread-worker.js");
  }
  return workers;
}

function terminateWorkers(workers) {
  for (let worker of workers) {
    worker.terminate();
  }
}
