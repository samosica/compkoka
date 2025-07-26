# test

## How to test

Run `script/test.sh`.

## How to add a test file

1. Create a test file as follows:

    ```koka
    // 1. Start with `module (filename)`.
    module binsearch

    import std/num/float64

    // 2. Import `base`.
    import base
    import ck/binsearch

    // 3. Define `main` function containing tests.
    // It must be public, that is, it must start with `pub`.
    pub fun main()
      // 4. Define a test using `test` function.
      // The first argument is the description.
      test("binsearch")
        // Equality test using `expect` function.
        // The former argument is the actual value,
        // and the latter one is the expected value.
        expect(binsearch(0, 200, fn(x) { x <= 87 }), 87)
    ```

2. Add the test file to `all.kk`:

    ```koka
    module all

    // Import the test file you created.
    import binsearch
    import fenwick
    import vector

    fun main()
      // Call `main` function in the imported module.
      binsearch/main()
      fenwick/main()
      vector/main()
    ```
