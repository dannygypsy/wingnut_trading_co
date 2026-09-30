import { spawn, spawnSync } from 'node:child_process'
import prisma from '../../../utils/prisma'

const PRINTER = process.env.LABEL_PRINTER ?? 'Zebra_Technologies_ZTC_ZD410_203dpi_ZPL'

const sizeMap: Record<string, string> = {
  XS: 'X-SMALL', S: 'SMALL', M: 'MEDIUM', L: 'LARGE',
  XL: 'X-LARGE', '2XL': '2X-LARGE', '3XL': '3X-LARGE', '4XL': '4X-LARGE'
}

export default defineEventHandler(async (event) => {
  const lprCheck = spawnSync('which', ['lpr'])
  if (lprCheck.status !== 0) {
    throw createError({ statusCode: 503, message: 'Label printing is only available when running locally.' })
  }

  const { inventoryId, quantity = 1 } = await readBody(event)
  if (!inventoryId) throw createError({ statusCode: 400, message: 'inventoryId is required' })

  const rows = await prisma.$queryRaw<any[]>`
    SELECT product_id, name, size, type, retail FROM wtc_inventory
    WHERE id = ${inventoryId} LIMIT 1`

  if (rows.length === 0) throw createError({ statusCode: 404, message: 'Item not found' })

  const item = rows[0]
  const sizeLabel = sizeMap[item.size] || item.size || ''
  const qrPayload = item.size ? `${item.product_id}|${item.size}` : item.product_id

  let price = parseFloat(item.retail) || 0
  let subPrice = ''
  if (item.type === 'blank') {
    price = price + 5
    subPrice = 'INCLUDES 1 TRANSFER'
  } else if (item.type === 'transfer') {
    subPrice = 'TRANSFER ONLY'
  }

  const zpl = [
    '^XA',
    '^PW400',
    '^LL200',
    '^LT10',
    '^FO05,10^FB400,1,0,C,0^A0N,30,30^FDWINGNUT TRADING COMPANY^FS',
    `^FO15,35^BQN,2,4,Q,7^FDMA,${qrPayload}^FS`,
    `^FO155,50^A0N,22,22^FD${item.name}^FS`,
    `^FO155,75^A0N,22,22^FD${sizeLabel}^FS`,
    `^FO155,105^A0N,60,60^FD$${price.toFixed(2)}^FS`,
    `^FO155,160^A0N,18,18^FD${subPrice}^FS`,
    `^PQ${quantity},0,1,Y`,
    '^XZ'
  ].join('\n')

  await new Promise<void>((resolve, reject) => {
    const proc = spawn('lpr', ['-P', PRINTER, '-o', 'raw'])
    proc.stdin.write(zpl)
    proc.stdin.end()
    proc.on('close', code => code === 0 ? resolve() : reject(new Error(`lpr exited ${code}`)))
    proc.on('error', reject)
  })

  console.log(`Label printed for inventory ${inventoryId}`)
  return { success: true }
})
