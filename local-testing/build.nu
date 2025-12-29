def main [] {
    let pdf_stds = ["1.7", "2.0"]
    let font_types = ["variable", "static"]

    # Flatten the matrix into a list of job objects
    let jobs = ($pdf_stds | each {|pdf|
        $font_types | each {|font|
            { pdf: $pdf, font: $font }
        }
    } | flatten)

    print $"🚀 Starting ($jobs | length) jobs in parallel..."

    $jobs | par-each {|job|
        print $"▶ [START] ($job.font) | PDF ($job.pdf)"

        # Run command directly so output streams to stdout/stderr
        ~/.cargo/target/debug/typst compile --font-path $"local-testing/fonts/($job.font)" --format pdf "local-testing/test.typ" $"local-testing/out/test-($job.font)-($job.pdf).pdf"

        print $"✅ [DONE]  ($job.font) | PDF ($job.pdf)"
    }

    print "✨ All tasks completed."
}
