import prisma from '../../utils/prisma'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const { startDate, endDate, type } = query as Record<string, string>

    const dateWhere: any = {}
    if (startDate) {
        dateWhere.transaction_date = { ...dateWhere.transaction_date, gte: new Date(startDate) }
    }
    if (endDate) {
        const end = new Date(endDate)
        end.setDate(end.getDate() + 1)
        dateWhere.transaction_date = { ...dateWhere.transaction_date, lt: end }
    }

    const listWhere: any = { ...dateWhere }
    if (type === 'income' || type === 'expense') {
        listWhere.type = type
    }

    const [transactions, incomeAgg, expenseAgg] = await Promise.all([
        prisma.cashFlow.findMany({
            where: listWhere,
            orderBy: { transaction_date: 'desc' }
        }),
        prisma.cashFlow.aggregate({
            where: { ...dateWhere, type: 'income' },
            _sum: { amount: true },
            _count: { _all: true }
        }),
        prisma.cashFlow.aggregate({
            where: { ...dateWhere, type: 'expense' },
            _sum: { amount: true },
            _count: { _all: true }
        })
    ])

    const totalIncome = Number(incomeAgg._sum.amount ?? 0)
    const totalExpenses = Number(expenseAgg._sum.amount ?? 0)

    return {
        summary: {
            totalIncome,
            totalExpenses,
            netCashFlow: totalIncome - totalExpenses,
            transactionCount: incomeAgg._count._all + expenseAgg._count._all
        },
        transactions: transactions.map(t => ({
            ...t,
            amount: Number(t.amount),
            transaction_date: t.transaction_date.toISOString()
        }))
    }
})