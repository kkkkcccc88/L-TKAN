# L-TKAN
use for article L-TKAN:A fast and accurate Laplacian radial basis function-Based Temporal Kolmogorov-Arnold Network for state of charge estimation of lithium-ion batteries
The relevant code has been open-sourced, and the libraries to be installed are listed in the first section of the code, consistent with the original TKAN. The datasets and data processing methods have also been provided. Key points to note include:

    MLP and KAN do not use a sliding window approach for data processing.

    The batch sizes during training are as follows:

        KAN, MLP, and TCN: 256

        Transformer: 512

        All other models: 1024

    The optimal sliding window size for GRU is set to 80.
