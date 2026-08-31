import { randomUUID } from 'crypto'

export default defineEventHandler(async (event) => {
    const body = await readBody(event)

    const id = randomUUID()
    const productId = body.product_id || randomUUID()

    const item = await prisma.inventory.create({
        data: {
            id,
            product_id: productId,
            category: body.category,
            name: body.name,
            size: body.size || null,
            full_name: body.full_name,
            type: body.type || null,
            cost: parseFloat(body.cost),
            retail: parseFloat(body.retail),
            purchased_on: new Date(body.purchased_on),
            num_purchased: parseInt(body.num_purchased),
            remaining: parseInt(body.num_purchased), // starts equal to purchased
            image: null,
        }
    })

    return item
})