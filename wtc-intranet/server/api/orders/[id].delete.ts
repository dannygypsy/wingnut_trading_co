export default defineEventHandler(async (event) => {
    const id = getRouterParam(event, 'id')
    if (!id) throw createError({ statusCode: 400, message: 'Missing order ID' })

    // Delete children first (foreign key constraints)
    await prisma.orderCustomization.deleteMany({ where: { order_id: id } })
    await prisma.orderItem.deleteMany({ where: { order_id: id } })
    await prisma.order.delete({ where: { id } })

    return { success: true }
})