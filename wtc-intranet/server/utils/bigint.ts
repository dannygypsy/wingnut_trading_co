export function sanitizeBigInt(val: unknown): unknown {
    return JSON.parse(JSON.stringify(val, (_, v) =>
        typeof v === 'bigint' ? Number(v) : v
    ))
}