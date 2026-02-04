A **clean mathematical view** of **(1) BER vs. SNR** and **(2) Jitter vs. Eye Width**, mapped to your SerDes (128b/130b → CDR → eye → BER). I’ll keep it rigorous but interview-ready.

---

# **1) BER vs. SNR — Mathematical View (Data Integrity)**

## 📌 Intuition first

Higher **SNR → cleaner signal → fewer bit errors → lower BER.**

---

## **A. Basic Channel Model**

For a binary PAM-2 (0/1) SerDes link, the received signal can be modeled as:

[
r(t) = s(t) + n(t)
]

where:

* ( s(t) ) = transmitted signal
* ( n(t) ) = additive white Gaussian noise (AWGN)

---

## **B. Define SNR**

[
\text{SNR} = \frac{P_{signal}}{P_{noise}} = \frac{A^2}{\sigma_n^2}
]

where:

* (A) = signal amplitude
* (\sigma_n^2) = noise variance

Often expressed in dB:

[
\text{SNR}*{dB} = 10 \log*{10} \left(\frac{A^2}{\sigma_n^2}\right)
]

---

## **C. BER for PAM-2 (Your SerDes-like case)**

For a simple binary link with Gaussian noise:

[
\boxed{
BER = Q\left(\sqrt{2 \cdot SNR}\right)
}
]

where (Q(x)) is the Q-function:

[
Q(x) = \frac{1}{\sqrt{2\pi}} \int_x^{\infty} e^{-t^2/2} dt
]

Equivalent form:

[
BER = \frac{1}{2} \operatorname{erfc}\left(\sqrt{SNR}\right)
]

---

## **D. What this means for your project**

As your **BER channel (`ber_channel.sv`) increases noise**, it effectively **reduces SNR**, which moves you along this curve:

![Image](https://www.researchgate.net/publication/287705444/figure/fig2/AS%3A920981614886912%401596590536506/Comparison-of-the-BER-vs-SNR-performance-graph-for.ppm)

![Image](https://upload.wikimedia.org/wikipedia/commons/c/c3/Q-function.png)

![Image](https://www.researchgate.net/publication/260245113/figure/fig2/AS%3A667834413764612%401536235540192/shows-the-plots-of-BER-versus-SNR-under-OOK-and-BPSK-modulation-format-by-using-a-fixed.ppm)

### Key takeaways you can say in interview:

* Every **+3 dB in SNR roughly halves the BER (in mid-region).**
* There is a **steep waterfall region** → small SNR changes cause huge BER changes.
* Your 128b/130b coding shifts the *effective* BER lower by detecting/correcting some errors.

---

## **E. Effective BER with 128b/130b Encoding**

If raw channel BER = (p), then probability that a **130-bit symbol is corrupted**:

[
P_{sym_err} = 1 - (1-p)^{130}
]

For small (p):

[
P_{sym_err} \approx 130p
]

Your decoder (`pcie_128b130b_decode.sv`) can **flag many of these as invalid**, effectively improving usable BER.

---

# **2) Jitter vs. Eye Width — Mathematical View (Timing Integrity)**

## 📌 Intuition first

More **jitter → narrower eye → less timing margin → higher BER.**

---

## **A. Total Jitter Model**

Total jitter (TJ) at a given BER is modeled as:

[
\boxed{
TJ(BER) = DJ + RJ(BER)
}
]

where:

* **DJ (Deterministic Jitter)** = bounded, systematic (ISI, duty cycle distortion, crosstalk)
* **RJ (Random Jitter)** = unbounded, Gaussian

---

## **B. Random Jitter vs. BER**

Random jitter grows with BER as:

[
RJ(BER) = k \cdot \sigma_{RJ}
]

where:

* ( \sigma_{RJ} ) = standard deviation of random jitter
* ( k ) depends on target BER

  * For BER = (10^{-12}), (k \approx 14)

So:

[
TJ(10^{-12}) \approx DJ + 14\sigma_{RJ}
]

This is exactly what your **bathtub curve (`plot_bathtub.py`)** visualizes.

![Image](https://www.mathworks.com/help/signal-integrity/ug/jitter_ber.png)

![Image](https://www.researchgate.net/publication/274641024/figure/fig10/AS%3A613921396379648%401523381675023/Eye-Diagram-Analysis.png)

![Image](https://help.altair.com/Pollex/images/pollex/serdes_statistical_eye_analysis_result_dialog_1.png)

---

## **C. Eye Width vs. Jitter**

Let:

* Unit interval = (UI = T_{bit})
* Nominal eye width = (W_0)

Then:

[
\boxed{
W_{effective} = W_0 - TJ(BER)
}
]

If:

[
TJ(BER) \ge W_0
]

→ **Eye closes → CDR fails → link breaks.**

---

## **D. Sampling Error Probability (Jitter → BER)**

If sampling point error (timing offset) is (\Delta t), and signal slope at crossing is (S), then voltage noise due to jitter is:

[
\sigma_v = S \cdot \sigma_t
]

Plugging into BER equation:

[
BER \approx Q\left(\frac{A}{\sigma_v}\right)
= Q\left(\frac{A}{S \cdot \sigma_t}\right)
]

👉 **More jitter ((\sigma_t)) → higher BER.**

This is what your:

* `jitter_channel.sv` stresses, and
* `cdr_model.sv` tries to correct.

---

# **3) BER–Jitter Coupling (Most Important Insight)**

They are **not independent**.

You can think of an **effective SNR degraded by jitter**:

[
SNR_{eff} = \frac{A^2}{\sigma_n^2 + (S \cdot \sigma_t)^2}
]

So final BER becomes:

[
\boxed{
BER = Q!\left(\sqrt{2 \cdot SNR_{eff}}\right)
}
]

This is why stressing **both BER + Jitter together** (your `ber_stress_seq.sv`) is realistic.

---

# **4) How this maps directly to your repo**

| Math Concept                | Your File                |
| --------------------------- | ------------------------ |
| Noise variance (\sigma_n^2) | `ber_channel.sv`         |
| Jitter std. dev. (\sigma_t) | `jitter_channel.sv`      |
| Sampling point optimization | `cdr_model.sv`           |
| Eye width (W_{eff})         | `eye_stats_collector.sv` |
| Bathtub (TJ(BER))           | `plot_bathtub.py`        |
| BER measurement             | Scoreboard + monitor     |

---

# **One-slide summary you can remember**

**Data plane (BER):**
[
BER = Q!\left(\sqrt{2\cdot SNR}\right)
]

**Timing plane (Jitter):**
[
TJ(BER) = DJ + 14\sigma_{RJ} \quad (@10^{-12})
]

**Eye margin:**
[
W_{eff} = UI - TJ(BER)
]

---


