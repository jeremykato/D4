# Ideas For Algorithms

## Neccessary Function:

1) **Hashing**: The following must be hashed in each block of the chain (I will refer to this as the input string):

`<block-num>|<previous-hash>|<transaction-string>|<timestamp-string>`

Note that the vertical bars *are* included as a part of the hash. The hash function, that I will accordingly refer to bill_hash from this point on, is the following:

`((x**3000) + (x**x) - (3**x)) * (7**x)`

2) **Data Validation**: The following must hold true for each block:

- The hash in the beginning of the block *must* match the previous block's hash value.
- The hash at the end of a block *must* be valid (match the computed value).
- Timestamps must go in ascending order as the blocks proceed.
- Data in each line must be in a valid format.
- At the end of each block, each user cannot have a negative balance.

In addition to the above, when an error is found, the program must tell the user where the error happened, what the error is, and if possible, what value was expected by the program.

## Naive

To calculate hash, simply do `bill_hash` for each value in the input string. After this is complete, sum the values mod 65536, and the hash is complete.

## Modular Exponentiation

Performing `bill_hash` naively will be horribly slow. Between the four terms of `bill_hash`, we will end up wih massive numbers extremely quickly. Given x = 5, performing x^3000 will return a massive number, and we end up performing modulus on it anyway.

During each step, use modular exponentiation to cut down on the numbers that are produced, thus making each successive exponentation much faster than the naive version.

## Caching

We're quickly going to begin seeing the same values repeated over and over. `bill_hash` merely does a sum of each character's UTF-8 value, but there's no point in recalculating values when we can just look them up in a map.

At the beginning of execution, create a hashmap that stores `bill_hash`s for each character. When reading a given character, check if it's in the hashmap, and if so, use the value, and if not, hash it and add it to the map.

## Multithreading

Though each block depends on the previous block, each block already has previous block's hash. We don't need to wait for a previous block to be verified before moving on to the next one, so why not bring some extra threads along to help us out.

Each thread is given a block to work on and the hash that the next block is using. Each thread computes their block's hash, and checks it against their block and the next block to ensure that the blockchain is valid. Note that this is compatible with caching because there is really no harm if multiple threads are reading or writing to the hashmap at the same time (even if they both write at the same time, they're doing the same values.)

## Hardware Accleration, OpenCL and other means
