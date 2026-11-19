import com.google.common.base.Charsets;
import com.google.common.hash.BloomFilter;
import com.google.common.hash.Funnels;

import java.io.*;

/**
 * Merges a baseline Bloom filter into a freshly built one (same size and hash functions, so the union is exact) and
 * prints the approximate entry count. Used to keep the signatures the upstream database accumulated over the years.
 * Usage: java MergeBloom <fresh.bin> <baseline.bin> <out.bin>
 */
public class MergeBloom {
    static BloomFilter<CharSequence> load(String path) throws IOException {
        try (InputStream in = new BufferedInputStream(new FileInputStream(path))) {
            return BloomFilter.readFrom(in, Funnels.stringFunnel(Charsets.US_ASCII));
        }
    }

    public static void main(String[] a) throws IOException {
        BloomFilter<CharSequence> fresh = load(a[0]);
        BloomFilter<CharSequence> base = load(a[1]);
        long before = fresh.approximateElementCount();
        if (!fresh.isCompatible(base)) throw new IllegalStateException("filters are not compatible: " + a[0] + " / " + a[1]);
        fresh.putAll(base);
        try (OutputStream out = new BufferedOutputStream(new FileOutputStream(a[2]))) { fresh.writeTo(out); }
        System.out.println(a[2] + " fresh=" + before + " baseline=" + base.approximateElementCount()
            + " merged=" + fresh.approximateElementCount() + " fpp=" + fresh.expectedFpp());
    }
}
